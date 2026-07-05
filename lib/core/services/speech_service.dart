import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Voice capture with graceful degradation: on platforms without a
/// speech engine (e.g. Linux desktop) [available] stays false and the
/// UI offers typing instead.
class SpeechService {
  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _available = false;

  bool get isListening => _speech.isListening;

  Future<bool> ensureAvailable() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      _available = await _speech.initialize();
    } catch (_) {
      // MissingPluginException on unsupported desktops — typing still works.
      _available = false;
    }
    return _available;
  }

  /// Starts listening; partial and final transcripts arrive via [onTranscript].
  /// Returns false when voice input is unavailable on this platform.
  Future<bool> start(ValueChanged<String> onTranscript) async {
    if (!await ensureAvailable()) return false;
    try {
      await _speech.listen(
        onResult: (result) => onTranscript(result.recognizedWords),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Nothing to stop on unsupported platforms.
    }
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
