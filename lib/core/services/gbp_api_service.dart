import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:google_business_profile_manager/core/services/oauth_loopback_stub.dart'
    if (dart.library.io) 'package:google_business_profile_manager/core/services/oauth_loopback_io.dart';
import 'package:google_business_profile_manager/core/utils/file_bytes_stub.dart'
    if (dart.library.io) 'package:google_business_profile_manager/core/utils/file_bytes_io.dart';

class GbpException implements Exception {
  GbpException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GbpAccount {
  const GbpAccount({required this.name, required this.title});

  /// "accounts/123456789"
  final String name;
  final String title;
}

class GbpLocation {
  const GbpLocation({
    required this.name,
    required this.title,
    this.address,
    this.category,
    this.phone,
    this.website,
    this.latitude,
    this.longitude,
  });

  /// "locations/123456789"
  final String name;
  final String title;
  final String? address;
  final String? category;
  final String? phone;
  final String? website;
  final double? latitude;
  final double? longitude;
}

/// Real Google Business Profile API client using the user's own
/// Google Cloud OAuth "Desktop app" credentials — no backend involved.
class GbpApiService {
  GbpApiService(this._keyStore, {Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));

  final KeyStoreService _keyStore;
  final Dio _dio;

  static const _scope = 'https://www.googleapis.com/auth/business.manage';
  static const _accountsBase = 'https://mybusinessaccountmanagement.googleapis.com/v1';
  static const _infoBase = 'https://mybusinessbusinessinformation.googleapis.com/v1';
  static const _v4Base = 'https://mybusiness.googleapis.com/v4';

  String? _accessToken;
  DateTime? _accessTokenExpiry;

  bool get hasCredentials => _keyStore.googleClientId != null && _keyStore.googleClientSecret != null;
  bool get isConnected => _keyStore.googleRefreshToken != null;

  /// Full interactive sign-in: browser consent → code → tokens.
  Future<void> connect() async {
    final clientId = _keyStore.googleClientId;
    final clientSecret = _keyStore.googleClientSecret;
    if (clientId == null || clientSecret == null) {
      throw GbpException(
        'Add your Google Cloud OAuth Client ID and secret in Settings first '
        '(create a "Desktop app" OAuth client with the Business Profile APIs enabled).',
      );
    }

    final OAuthLoopbackResult result;
    try {
      result = await runOAuthLoopback(
        clientId: clientId,
        scopes: const [_scope],
        launchConsent: (url) => launchUrl(url, mode: LaunchMode.externalApplication),
      );
    } on UnsupportedError catch (error) {
      throw GbpException(error.message ?? 'Sign-in is not supported on this platform.');
    }

    final response = await _dio.post(
      'https://oauth2.googleapis.com/token',
      options: Options(contentType: Headers.formUrlEncodedContentType),
      data: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': result.code,
        'grant_type': 'authorization_code',
        'redirect_uri': result.redirectUri,
      },
    );

    final data = response.data;
    if (data is! Map || data['refresh_token'] == null) {
      throw GbpException('Google did not return a refresh token. Try removing prior consent at '
          'myaccount.google.com/permissions and reconnecting.');
    }
    await _keyStore.setGoogleRefreshToken(data['refresh_token'].toString());
    _accessToken = data['access_token']?.toString();
    _accessTokenExpiry = DateTime.now().add(Duration(seconds: (data['expires_in'] as num? ?? 3600).toInt() - 60));
  }

  Future<void> disconnect() async {
    await _keyStore.setGoogleRefreshToken(null);
    _accessToken = null;
    _accessTokenExpiry = null;
  }

  Future<String> _token() async {
    final cached = _accessToken;
    if (cached != null && _accessTokenExpiry != null && DateTime.now().isBefore(_accessTokenExpiry!)) {
      return cached;
    }
    final refreshToken = _keyStore.googleRefreshToken;
    if (refreshToken == null) {
      throw GbpException('Not connected to Google. Connect your account in Settings → Google Business Profile.');
    }
    try {
      final response = await _dio.post(
        'https://oauth2.googleapis.com/token',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'client_id': _keyStore.googleClientId,
          'client_secret': _keyStore.googleClientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );
      final data = response.data as Map;
      final token = data['access_token']?.toString();
      if (token == null) throw GbpException('Token refresh failed.');
      _accessToken = token;
      _accessTokenExpiry =
          DateTime.now().add(Duration(seconds: (data['expires_in'] as num? ?? 3600).toInt() - 60));
      return token;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400 || error.response?.statusCode == 401) {
        await disconnect();
        throw GbpException('Google session expired — please reconnect in Settings.');
      }
      throw GbpException('Could not refresh Google access: ${_apiError(error)}');
    }
  }

  Future<Options> _authOptions() async =>
      Options(headers: {'Authorization': 'Bearer ${await _token()}'});

  Future<List<GbpAccount>> listAccounts() async {
    try {
      final accounts = <GbpAccount>[];
      String? pageToken;
      do {
        final response = await _dio.get(
          '$_accountsBase/accounts',
          queryParameters: {
            'pageSize': 20,
            if (pageToken != null) 'pageToken': pageToken,
          },
          options: await _authOptions(),
        );
        final data = response.data as Map;
        final page = data['accounts'];
        if (page is List) {
          accounts.addAll(page
              .whereType<Map>()
              .map((item) => GbpAccount(
                    name: item['name']?.toString() ?? '',
                    title: item['accountName']?.toString() ?? item['name']?.toString() ?? 'Account',
                  ))
              .where((account) => account.name.isNotEmpty));
        }
        pageToken = data['nextPageToken']?.toString();
      } while (pageToken != null && pageToken.isNotEmpty);
      return accounts;
    } on DioException catch (error) {
      throw GbpException('Could not list Business Profile accounts: ${_apiError(error)}');
    }
  }

  Future<List<GbpLocation>> listLocations(String accountName) async {
    try {
      final locations = <GbpLocation>[];
      String? pageToken;
      do {
        final response = await _dio.get(
          '$_infoBase/$accountName/locations',
          queryParameters: {
            'readMask': 'name,title,storefrontAddress,phoneNumbers,websiteUri,latlng,categories',
            'pageSize': 100,
            if (pageToken != null) 'pageToken': pageToken,
          },
          options: await _authOptions(),
        );
        final data = response.data as Map;
        final page = data['locations'];
        if (page is List) {
          locations.addAll(page
              .whereType<Map>()
              .map(_parseLocation)
              .where((location) => location.name.isNotEmpty));
        }
        pageToken = data['nextPageToken']?.toString();
      } while (pageToken != null && pageToken.isNotEmpty);
      return locations;
    } on DioException catch (error) {
      throw GbpException('Could not list locations: ${_apiError(error)}');
    }
  }

  GbpLocation _parseLocation(Map item) {
    final address = item['storefrontAddress'];
    String? formatted;
    if (address is Map) {
      final lines = (address['addressLines'] as List?)?.join(', ');
      formatted = [lines, address['locality'], address['regionCode']]
          .where((part) => part != null && part.toString().isNotEmpty)
          .join(', ');
    }
    final phones = item['phoneNumbers'];
    final latlng = item['latlng'];
    final categories = item['categories'];
    String? category;
    if (categories is Map && categories['primaryCategory'] is Map) {
      category = (categories['primaryCategory'] as Map)['displayName']?.toString();
    }
    return GbpLocation(
      name: item['name']?.toString() ?? '',
      title: item['title']?.toString() ?? 'Location',
      address: formatted,
      category: category,
      phone: phones is Map ? phones['primaryPhone']?.toString() : null,
      website: item['websiteUri']?.toString(),
      latitude: latlng is Map ? (latlng['latitude'] as num?)?.toDouble() : null,
      longitude: latlng is Map ? (latlng['longitude'] as num?)?.toDouble() : null,
    );
  }

  /// Pushes editable profile fields to the linked GBP location.
  Future<void> updateLocation({
    required String locationName,
    String? title,
    String? phone,
    String? websiteUri,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    final mask = <String>[];
    if (title != null && title.isNotEmpty) {
      body['title'] = title;
      mask.add('title');
    }
    if (phone != null && phone.isNotEmpty) {
      body['phoneNumbers'] = {'primaryPhone': phone};
      mask.add('phoneNumbers.primaryPhone');
    }
    if (websiteUri != null && websiteUri.isNotEmpty) {
      body['websiteUri'] = websiteUri;
      mask.add('websiteUri');
    }
    if (latitude != null && longitude != null) {
      body['latlng'] = {'latitude': latitude, 'longitude': longitude};
      mask.add('latlng');
    }
    if (mask.isEmpty) return;
    try {
      await _dio.patch(
        '$_infoBase/$locationName',
        queryParameters: {'updateMask': mask.join(','), 'validateOnly': false},
        options: await _authOptions(),
        data: body,
      );
    } on DioException catch (error) {
      throw GbpException('Location update failed: ${_apiError(error)}');
    }
  }

  /// Publishes a local post ("What's new" / offer). Google's public API has
  /// no product-catalog endpoint, so staged products are published as posts.
  Future<void> publishLocalPost({
    required String accountName,
    required String locationName,
    required String summary,
    String topicType = 'STANDARD',
    String? ctaUrl,
    String? languageCode,
  }) async {
    final parent = '$accountName/$locationName';
    final body = <String, dynamic>{
      'languageCode': languageCode ?? 'en',
      'topicType': topicType,
      'summary': summary.length > 1500 ? summary.substring(0, 1500) : summary,
      if (ctaUrl != null && ctaUrl.isNotEmpty)
        'callToAction': {'actionType': 'LEARN_MORE', 'url': ctaUrl},
    };
    try {
      await _dio.post(
        '$_v4Base/$parent/localPosts',
        options: await _authOptions(),
        data: body,
      );
    } on DioException catch (error) {
      throw GbpException('Post publish failed: ${_apiError(error)}');
    }
  }

  /// Uploads a local photo into the location's media gallery.
  Future<void> uploadPhoto({
    required String accountName,
    required String locationName,
    required String imagePath,
  }) async {
    final parent = '$accountName/$locationName';
    try {
      final start = await _dio.post(
        '$_v4Base/$parent/media:startUpload',
        options: await _authOptions(),
        data: const <String, dynamic>{},
      );
      final resourceName = (start.data as Map)['resourceName']?.toString();
      if (resourceName == null) throw GbpException('Media upload could not be initialized.');

      final bytes = await readFileBytes(imagePath);
      await _dio.post(
        'https://mybusiness.googleapis.com/upload/v1/media/$resourceName?upload_type=media',
        options: Options(headers: {
          'Authorization': 'Bearer ${await _token()}',
          'Content-Type': 'application/octet-stream',
        }),
        data: Stream.fromIterable([bytes]),
      );

      await _dio.post(
        '$_v4Base/$parent/media',
        options: await _authOptions(),
        data: {
          'mediaFormat': 'PHOTO',
          'locationAssociation': {'category': 'ADDITIONAL'},
          'dataRef': {'resourceName': resourceName},
        },
      );
    } on GbpException {
      rethrow;
    } on DioException catch (error) {
      throw GbpException('Photo upload failed: ${_apiError(error)}');
    }
  }

  String _apiError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String detail = error.message ?? 'network error';
    if (data is Map && data['error'] is Map) {
      detail = (data['error'] as Map)['message']?.toString() ?? detail;
    } else if (data != null) {
      detail = data.toString();
    }
    if (detail.length > 400) detail = detail.substring(0, 400);
    return status == null ? detail : 'HTTP $status — $detail';
  }
}

final gbpApiServiceProvider = Provider<GbpApiService>((ref) {
  return GbpApiService(ref.watch(keyStoreProvider));
});
