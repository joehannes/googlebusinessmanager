import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI backends the user can bring a free key for.
enum AiProvider { gemini, qwen }

/// Local-first settings/key store. Everything stays on-device — no backend.
class KeyStoreService {
  KeyStoreService(this._prefs);

  static const _onboardingKey = 'onboarding_completed';
  static const _aiProviderKey = 'ai_provider';
  static const _geminiApiKey = 'gemini_api_key';
  static const _geminiModelKey = 'gemini_model';
  static const _openRouterApiKey = 'openrouter_api_key';
  static const _qwenTextModelKey = 'qwen_text_model';
  static const _qwenVisionModelKey = 'qwen_vision_model';
  static const _googleClientIdKey = 'google_oauth_client_id';
  static const _googleClientSecretKey = 'google_oauth_client_secret';
  static const _googleRefreshTokenKey = 'google_refresh_token';
  static const _activeBusinessKey = 'active_business_id';

  static const defaultGeminiModel = 'gemini-2.0-flash';
  static const defaultQwenTextModel = 'qwen/qwen-2.5-72b-instruct';
  static const defaultQwenVisionModel = 'qwen/qwen2.5-vl-72b-instruct';

  final SharedPreferences _prefs;

  static Future<KeyStoreService> create() async {
    return KeyStoreService(await SharedPreferences.getInstance());
  }

  bool get onboardingCompleted => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_onboardingKey, value);

  AiProvider get aiProvider =>
      _prefs.getString(_aiProviderKey) == 'qwen' ? AiProvider.qwen : AiProvider.gemini;
  Future<void> setAiProvider(AiProvider provider) => _prefs.setString(_aiProviderKey, provider.name);

  String? get geminiApiKey => _emptyToNull(_prefs.getString(_geminiApiKey));
  Future<void> setGeminiApiKey(String value) => _prefs.setString(_geminiApiKey, value.trim());

  String get geminiModel => _emptyToNull(_prefs.getString(_geminiModelKey)) ?? defaultGeminiModel;
  Future<void> setGeminiModel(String value) => _prefs.setString(_geminiModelKey, value.trim());

  String? get openRouterApiKey => _emptyToNull(_prefs.getString(_openRouterApiKey));
  Future<void> setOpenRouterApiKey(String value) => _prefs.setString(_openRouterApiKey, value.trim());

  String get qwenTextModel =>
      _emptyToNull(_prefs.getString(_qwenTextModelKey)) ?? defaultQwenTextModel;
  Future<void> setQwenTextModel(String value) => _prefs.setString(_qwenTextModelKey, value.trim());

  String get qwenVisionModel =>
      _emptyToNull(_prefs.getString(_qwenVisionModelKey)) ?? defaultQwenVisionModel;
  Future<void> setQwenVisionModel(String value) => _prefs.setString(_qwenVisionModelKey, value.trim());

  /// Key for whichever provider is currently active, if configured.
  String? get activeAiKey =>
      aiProvider == AiProvider.gemini ? geminiApiKey : openRouterApiKey;

  String? get googleClientId => _emptyToNull(_prefs.getString(_googleClientIdKey));
  Future<void> setGoogleClientId(String value) => _prefs.setString(_googleClientIdKey, value.trim());

  String? get googleClientSecret => _emptyToNull(_prefs.getString(_googleClientSecretKey));
  Future<void> setGoogleClientSecret(String value) =>
      _prefs.setString(_googleClientSecretKey, value.trim());

  String? get googleRefreshToken => _emptyToNull(_prefs.getString(_googleRefreshTokenKey));
  Future<void> setGoogleRefreshToken(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_googleRefreshTokenKey);
    } else {
      await _prefs.setString(_googleRefreshTokenKey, value);
    }
  }

  int? get activeBusinessId => _prefs.getInt(_activeBusinessKey);
  Future<void> setActiveBusinessId(int? id) async {
    if (id == null) {
      await _prefs.remove(_activeBusinessKey);
    } else {
      await _prefs.setInt(_activeBusinessKey, id);
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// Overridden in main() with the initialized instance.
final keyStoreProvider = Provider<KeyStoreService>((ref) {
  throw UnimplementedError('keyStoreProvider must be overridden in main()');
});
