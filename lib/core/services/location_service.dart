import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GeocodeResult {
  const GeocodeResult({required this.point, required this.displayName});
  final LatLng point;
  final String displayName;
}

/// Device GPS (where supported) plus free OSM/Nominatim geocoding —
/// no API key or credit card required.
class LocationService {
  LocationService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));

  final Dio _dio;

  static const _nominatimHeaders = {
    'User-Agent': 'google-business-profile-manager/1.0 (local-first Flutter app)',
  };

  /// Current device position, or null where GPS/permission is unavailable
  /// (e.g. Linux desktop) — the map picker then falls back to search/drag.
  Future<LatLng?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // No geolocator implementation on this platform.
      return null;
    }
  }

  /// Free-text address search (forward geocoding).
  Future<List<GeocodeResult>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {'q': query, 'format': 'jsonv2', 'limit': 5},
      options: Options(headers: _nominatimHeaders),
    );
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat == null || lon == null) return null;
          return GeocodeResult(
            point: LatLng(lat, lon),
            displayName: item['display_name']?.toString() ?? '$lat, $lon',
          );
        })
        .whereType<GeocodeResult>()
        .toList();
  }

  /// Human-readable place name for coordinates — feeds the AI's local
  /// pricing context ("Punta Cana, Dominican Republic" etc.).
  Future<String?> reverseLookup(LatLng point) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'jsonv2',
          'zoom': 10,
        },
        options: Options(headers: _nominatimHeaders),
      );
      final data = response.data;
      if (data is Map) return data['display_name']?.toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
