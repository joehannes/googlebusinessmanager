import 'dart:async';
import 'dart:io';

/// Runs the OAuth 2.0 "installed app" loopback flow: starts a temporary
/// localhost server, opens the Google consent page in the browser, and
/// captures the authorization code on redirect.
Future<OAuthLoopbackResult> runOAuthLoopback({
  required String clientId,
  required List<String> scopes,
  required Future<bool> Function(Uri consentUrl) launchConsent,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final redirectUri = 'http://127.0.0.1:${server.port}';
  try {
    final consentUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
    });

    final launched = await launchConsent(consentUrl);
    if (!launched) {
      throw StateError('Could not open the browser for Google sign-in.');
    }

    // Browsers may hit the loopback server with unrelated requests
    // (e.g. /favicon.ico) — only the redirect carrying code/error counts.
    final redirect = Completer<HttpRequest>();
    final subscription = server.listen((request) {
      final params = request.uri.queryParameters;
      if (params.containsKey('code') || params.containsKey('error')) {
        if (!redirect.isCompleted) redirect.complete(request);
      } else {
        request.response.statusCode = 404;
        request.response.close();
      }
    });

    final HttpRequest request;
    try {
      request = await redirect.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('Google sign-in timed out after 5 minutes.'),
      );
    } finally {
      await subscription.cancel();
    }
    final code = request.uri.queryParameters['code'];
    final error = request.uri.queryParameters['error'];

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.html
      ..write(
        '<html><body style="font-family:sans-serif;text-align:center;padding-top:4em">'
        '<h2>${code != null ? 'Connected!' : 'Sign-in failed'}</h2>'
        '<p>You can close this tab and return to the Business Profile Manager.</p>'
        '</body></html>',
      );
    await request.response.close();

    if (code == null) {
      throw StateError('Google sign-in was denied${error == null ? '' : ' ($error)'}.');
    }
    return OAuthLoopbackResult(code: code, redirectUri: redirectUri);
  } finally {
    await server.close(force: true);
  }
}

class OAuthLoopbackResult {
  const OAuthLoopbackResult({required this.code, required this.redirectUri});
  final String code;
  final String redirectUri;
}
