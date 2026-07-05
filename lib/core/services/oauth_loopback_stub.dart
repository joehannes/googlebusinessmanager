/// Web fallback: the installed-app loopback flow needs a local HTTP
/// server, which browsers cannot provide.
Future<OAuthLoopbackResult> runOAuthLoopback({
  required String clientId,
  required List<String> scopes,
  required Future<bool> Function(Uri consentUrl) launchConsent,
}) async {
  throw UnsupportedError(
    'Google sign-in via loopback is available in the desktop and mobile apps. '
    'Please connect from the installed app.',
  );
}

class OAuthLoopbackResult {
  const OAuthLoopbackResult({required this.code, required this.redirectUri});
  final String code;
  final String redirectUri;
}
