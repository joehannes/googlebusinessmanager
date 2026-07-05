import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/gbp_import_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// One-time guided welcome: the "magic showcase" carousel, a zero-cost AI
/// key wizard with a real verification ping (confetti on success), and the
/// optional Google Cloud OAuth walkthrough.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));
  final TextEditingController _aiKey = TextEditingController();
  final TextEditingController _clientId = TextEditingController();
  final TextEditingController _clientSecret = TextEditingController();

  int _page = 0;
  AiProvider _provider = AiProvider.gemini;
  bool _testing = false;
  bool _keyVerified = false;
  String? _keyError;
  bool _connecting = false;
  String? _googleError;
  GbpImportResult? _importResult;

  static const _pageCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _confetti.dispose();
    _aiKey.dispose();
    _clientId.dispose();
    _clientSecret.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page.clamp(0, _pageCount - 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _testKey() async {
    final key = _aiKey.text.trim();
    if (key.isEmpty) {
      setState(() => _keyError = 'Paste the key first — the button below opens the right page.');
      return;
    }
    setState(() {
      _testing = true;
      _keyError = null;
    });
    final keyStore = ref.read(keyStoreProvider);
    try {
      await ref.read(aiServiceProvider).testConnection(provider: _provider, apiKey: key);
      await keyStore.setAiProvider(_provider);
      if (_provider == AiProvider.gemini) {
        await keyStore.setGeminiApiKey(key);
      } else {
        await keyStore.setOpenRouterApiKey(key);
      }
      setState(() => _keyVerified = true);
      _confetti.play();
    } on AiException catch (error) {
      setState(() => _keyError = error.message);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  /// Saves the OAuth credentials, runs the browser Google sign-in and pulls
  /// every business.google.com listing into the workspace list.
  Future<void> _connectGoogle() async {
    final clientId = _clientId.text.trim();
    final clientSecret = _clientSecret.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      setState(() => _googleError =
          'Paste your OAuth Client ID and secret first (steps above), then connect.');
      return;
    }
    setState(() {
      _connecting = true;
      _googleError = null;
    });
    final keyStore = ref.read(keyStoreProvider);
    await keyStore.setGoogleClientId(clientId);
    await keyStore.setGoogleClientSecret(clientSecret);
    try {
      final result = await ref.read(gbpImportServiceProvider).connectAndImport();
      if (!mounted) return;
      setState(() => _importResult = result);
      if (result.imported > 0) _confetti.play();
    } on GbpException catch (error) {
      setState(() => _googleError = error.message);
    } catch (error) {
      setState(() => _googleError = 'Google connection failed: $error');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _finish() async {
    final keyStore = ref.read(keyStoreProvider);
    if (_clientId.text.trim().isNotEmpty) {
      await keyStore.setGoogleClientId(_clientId.text);
      await keyStore.setGoogleClientSecret(_clientSecret.text);
    }
    await keyStore.setOnboardingCompleted(true);
    if (mounted) context.go('/businesses');
  }

  void _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _page = page),
                    children: [
                      _welcomePage(context),
                      _voiceShowcasePage(context),
                      _visionShowcasePage(context),
                      _aiKeyWizardPage(context),
                      _googleCloudPage(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Row(
                    children: [
                      if (_page < _pageCount - 1)
                        TextButton(
                          onPressed: _finish,
                          child: const Text('Skip tour'),
                        ),
                      const Spacer(),
                      for (var i = 0; i < _pageCount; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _page == _pageCount - 1 ? _finish : () => _goTo(_page + 1),
                        child: Text(_page == _pageCount - 1 ? 'Launch workspace' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              emissionFrequency: 0.4,
              numberOfParticles: 24,
              maxBlastForce: 25,
              shouldLoop: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageShell(BuildContext context, {required List<Widget> children}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: children,
        ),
      ),
    );
  }

  Widget _welcomePage(BuildContext context) {
    final theme = Theme.of(context);
    return _pageShell(context, children: [
      Icon(Icons.storefront, size: 72, color: theme.colorScheme.primary),
      const SizedBox(height: 24),
      Text('Welcome to your Business Profile studio',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const Text(
        'Manage every business.google.com listing you own — from your phone, browser or desktop. '
        'Local-first: your data and API keys live on your device, nowhere else.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      const Card(
        child: ListTile(
          leading: Icon(Icons.workspaces_outline),
          title: Text('Multiple businesses, isolated workspaces'),
          subtitle: Text('Switch between listings — catalogs and AI history never mix.'),
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.money_off),
          title: Text('Zero-cost AI'),
          subtitle: Text('Runs on free AI keys (no credit card) and free OpenStreetMap.'),
        ),
      ),
    ]);
  }

  Widget _voiceShowcasePage(BuildContext context) {
    final theme = Theme.of(context);
    return _pageShell(context, children: [
      Icon(Icons.mic, size: 64, color: theme.colorScheme.secondary),
      const SizedBox(height: 24),
      Text('Speak — the AI writes', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Card(
        color: theme.colorScheme.primaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '“These are new beachfront rental properties. Target American and European investors. '
            'Generate descriptions in English and Spanish. Set prices based on typical seasonal rates.”',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(Icons.translate),
          title: Text('Bilingual SEO descriptions'),
          subtitle: Text('One dictation → polished English & Spanish catalog texts.'),
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.article_outlined),
          title: Text('Blog & profile posts'),
          subtitle: Text('Auto-drafted for your key products, audiences and goals.'),
        ),
      ),
    ]);
  }

  Widget _visionShowcasePage(BuildContext context) {
    final theme = Theme.of(context);
    return _pageShell(context, children: [
      Icon(Icons.center_focus_strong, size: 64, color: theme.colorScheme.secondary),
      const SizedBox(height: 24),
      Text('Snap photos — get a catalog', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const Text(
        'Upload up to 20 product photos at once. Free vision AI recognizes each item, writes the '
        'description and estimates the typical LOCAL market price for your region.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      const Card(
        child: ListTile(
          leading: Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          title: Text('You stay in control'),
          subtitle: Text('AI price estimates glow amber until you verify them — '
              'nothing unverified is ever published.'),
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.grid_view),
          title: Text('Human-in-the-loop staging'),
          subtitle: Text('Every draft lands in an editable catalog before it syncs to Google.'),
        ),
      ),
    ]);
  }

  Widget _aiKeyWizardPage(BuildContext context) {
    final theme = Theme.of(context);
    return _pageShell(context, children: [
      Icon(Icons.vpn_key_outlined, size: 56, color: theme.colorScheme.primary),
      const SizedBox(height: 16),
      Text('Step 1 — your free AI key', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text(
        'Takes about 2 minutes, needs no credit card, and stays on this device.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      SegmentedButton<AiProvider>(
        segments: const [
          ButtonSegment(value: AiProvider.gemini, label: Text('Gemini ★')),
          ButtonSegment(value: AiProvider.qwen, label: Text('Qwen')),
        ],
        selected: {_provider},
        onSelectionChanged: (selection) => setState(() {
          _provider = selection.first;
          _keyVerified = false;
          _keyError = null;
        }),
      ),
      const SizedBox(height: 16),
      if (_provider == AiProvider.gemini) ...[
        const Text('1. Sign in with any Google account.\n'
            '2. Click "Create API key".\n'
            '3. Copy it and paste it below.'),
        TextButton.icon(
          onPressed: () => _open('https://aistudio.google.com/apikey'),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open Google AI Studio (free)'),
        ),
      ] else ...[
        const Text('1. Create a free OpenRouter account.\n'
            '2. Open "Keys" and create a key.\n'
            '3. Copy it and paste it below (Qwen text + vision models).'),
        TextButton.icon(
          onPressed: () => _open('https://openrouter.ai/keys'),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open OpenRouter'),
        ),
      ],
      const SizedBox(height: 8),
      TextField(
        controller: _aiKey,
        obscureText: true,
        decoration: InputDecoration(
          labelText: '${_provider == AiProvider.gemini ? 'Gemini' : 'OpenRouter'} API key',
          errorText: _keyError,
          errorMaxLines: 4,
        ),
        onChanged: (_) => setState(() => _keyVerified = false),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _testing ? null : _testKey,
        icon: _testing
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(_keyVerified ? Icons.check_circle : Icons.rocket_launch),
        label: Text(_keyVerified ? 'Verified — it works!' : 'Test & save key'),
      ),
      if (_keyVerified)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('🎉 Your AI copilot is live. You can change the key any time in Settings.',
              textAlign: TextAlign.center),
        ),
      const SizedBox(height: 8),
      const Text('You can also skip this and add the key later in Settings.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
    ]);
  }

  Widget _googleCloudPage(BuildContext context) {
    final theme = Theme.of(context);
    return _pageShell(context, children: [
      Icon(Icons.cloud_outlined, size: 56, color: theme.colorScheme.primary),
      const SizedBox(height: 16),
      Text('Step 2 — connect Google (optional)',
          style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text(
        'Sign in with your Google account and every business.google.com listing you manage '
        'is imported automatically — ready to work on the moment you launch the workspace. '
        'You can also skip this and set it up later in Settings.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('1. Create a (free) Google Cloud project.\n'
              '2. Enable: My Business Account Management API, My Business Business Information API, '
              'Google My Business API.\n'
              '3. OAuth consent screen → External → add yourself as test user.\n'
              '4. Credentials → Create OAuth Client ID → type "Desktop app".\n'
              '5. Paste Client ID & secret below.'),
        ),
      ),
      TextButton.icon(
        onPressed: () => _open('https://console.cloud.google.com/apis/credentials'),
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text('Open Google Cloud Console'),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _clientId,
        decoration: const InputDecoration(labelText: 'OAuth Client ID (optional now)'),
        onChanged: (_) => setState(() => _googleError = null),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _clientSecret,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'OAuth Client secret (optional now)',
          errorText: _googleError,
          errorMaxLines: 5,
        ),
        onChanged: (_) => setState(() => _googleError = null),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _connecting ? null : _connectGoogle,
        icon: _connecting
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(_importResult == null ? Icons.login : Icons.check_circle),
        label: Text(_connecting
            ? 'Fetching your businesses…'
            : _importResult == null
                ? 'Connect Google & import my businesses'
                : 'Connected — import again'),
      ),
      if (_importResult != null)
        Card(
          margin: const EdgeInsets.only(top: 12),
          color: theme.colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(_importResult!.imported > 0
                ? '🎉 Imported ${_importResult!.imported} '
                    'business${_importResult!.imported == 1 ? '' : 'es'} from Google'
                : 'Google connected — all ${_importResult!.total} '
                    'listing${_importResult!.total == 1 ? ' was' : 's were'} already imported'),
            subtitle: Text(_importResult!.skipped > 0 && _importResult!.imported > 0
                ? '${_importResult!.skipped} already existed. '
                    'They are waiting in your Business Profiles screen.'
                : 'They are waiting in your Business Profiles screen — '
                    'hit "Launch workspace" to start.'),
          ),
        ),
    ]);
  }
}
