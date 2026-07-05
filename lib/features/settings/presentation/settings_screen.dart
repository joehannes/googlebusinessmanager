import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _geminiKey;
  late final TextEditingController _geminiModel;
  late final TextEditingController _openRouterKey;
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;

  late AiProvider _provider;
  bool _testing = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    final keyStore = ref.read(keyStoreProvider);
    _provider = keyStore.aiProvider;
    _geminiKey = TextEditingController(text: keyStore.geminiApiKey ?? '');
    _geminiModel = TextEditingController(text: keyStore.geminiModel);
    _openRouterKey = TextEditingController(text: keyStore.openRouterApiKey ?? '');
    _clientId = TextEditingController(text: keyStore.googleClientId ?? '');
    _clientSecret = TextEditingController(text: keyStore.googleClientSecret ?? '');
  }

  @override
  void dispose() {
    for (final controller in [_geminiKey, _geminiModel, _openRouterKey, _clientId, _clientSecret]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAndTestAiKey() async {
    final keyStore = ref.read(keyStoreProvider);
    setState(() => _testing = true);
    try {
      await keyStore.setAiProvider(_provider);
      if (_provider == AiProvider.gemini) {
        await keyStore.setGeminiApiKey(_geminiKey.text);
        await keyStore.setGeminiModel(_geminiModel.text);
      } else {
        await keyStore.setOpenRouterApiKey(_openRouterKey.text);
      }
      await ref.read(aiServiceProvider).testConnection(provider: _provider);
      _toast('✓ Key works — AI features are live.');
    } on AiException catch (error) {
      _toast(error.message);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _saveGoogleCredentials() async {
    final keyStore = ref.read(keyStoreProvider);
    await keyStore.setGoogleClientId(_clientId.text);
    await keyStore.setGoogleClientSecret(_clientSecret.text);
    _toast('Google credentials saved locally.');
  }

  Future<void> _connectGoogle() async {
    await _saveGoogleCredentials();
    setState(() => _connecting = true);
    try {
      await ref.read(gbpApiServiceProvider).connect();
      _toast('✓ Connected to Google Business Profile.');
    } on GbpException catch (error) {
      _toast(error.message);
    } catch (error) {
      _toast('Connection failed: $error');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _replayTour() async {
    await ref.read(keyStoreProvider).setOnboardingCompleted(false);
    if (mounted) context.go('/onboarding');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 5)));
  }

  void _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final gbp = ref.watch(gbpApiServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- AI provider ----------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI assistant key', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text('Bring your own free key — it never leaves this device.'),
                  const SizedBox(height: 12),
                  SegmentedButton<AiProvider>(
                    segments: const [
                      ButtonSegment(
                        value: AiProvider.gemini,
                        icon: Icon(Icons.flash_on),
                        label: Text('Gemini'),
                      ),
                      ButtonSegment(
                        value: AiProvider.qwen,
                        icon: Icon(Icons.polyline),
                        label: Text('Qwen'),
                      ),
                    ],
                    selected: {_provider},
                    onSelectionChanged: (selection) => setState(() => _provider = selection.first),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _provider == AiProvider.gemini
                        ? 'Gemini — recommended free tier via Google AI Studio.'
                        : 'Qwen text + vision via your OpenRouter account.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (_provider == AiProvider.gemini) ...[
                    const Text('Free tier, no credit card — only a Google account. '
                        'Create the key in Google AI Studio.'),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _open('https://aistudio.google.com/apikey'),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Open Google AI Studio'),
                    ),
                    TextField(
                      controller: _geminiKey,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Gemini API key'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _geminiModel,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        helperText: 'Default: ${KeyStoreService.defaultGeminiModel}',
                      ),
                    ),
                  ] else ...[
                    const Text('Qwen text + vision models through your OpenRouter account.'),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _open('https://openrouter.ai/keys'),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Open OpenRouter keys'),
                    ),
                    TextField(
                      controller: _openRouterKey,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'OpenRouter API key'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _testing ? null : _saveAndTestAiKey,
                    icon: _testing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Save & test key'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Google Cloud ----------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Google Business Profile access', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    gbp.isConnected
                        ? '✓ Connected — you can link businesses and publish.'
                        : 'To publish to business.google.com, create free OAuth credentials once:',
                  ),
                  if (!gbp.isConnected) ...[
                    const SizedBox(height: 8),
                    const Text('1. Create a Google Cloud project (free).\n'
                        '2. Enable "My Business Account Management API", "My Business Business Information API" and "Google My Business API".\n'
                        '3. Configure the OAuth consent screen (External, add yourself as test user).\n'
                        '4. Create an OAuth Client ID of type "Desktop app" and paste it below.'),
                    TextButton.icon(
                      onPressed: () => _open('https://console.cloud.google.com/apis/credentials'),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Open Google Cloud Console'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: _clientId,
                    decoration: const InputDecoration(labelText: 'OAuth Client ID'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _clientSecret,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'OAuth Client secret'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _saveGoogleCredentials,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save credentials'),
                      ),
                      FilledButton.icon(
                        onPressed: _connecting ? null : _connectGoogle,
                        icon: _connecting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.login),
                        label: Text(gbp.isConnected ? 'Reconnect Google account' : 'Connect Google account'),
                      ),
                      if (gbp.isConnected)
                        OutlinedButton.icon(
                          onPressed: () async {
                            await gbp.disconnect();
                            setState(() {});
                            _toast('Disconnected from Google.');
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Disconnect'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Misc ----------------
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Local-first privacy'),
                  subtitle: Text('Businesses, drafts and API keys are stored only on this device. '
                      'Data leaves it exclusively when you call the AI or publish to Google.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.replay),
                  title: const Text('Replay the guided tour'),
                  subtitle: const Text('Revisit the welcome walkthrough and setup wizard.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _replayTour,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
