import 'dart:async';

import 'package:dio/dio.dart';

/// Serializes AI requests and paces them so free-tier rate limits
/// (e.g. 15 requests/minute on Gemini free keys) are never tripped
/// during bulk image processing. Retries once transparently on 429.
class RequestQueue {
  RequestQueue({this.minInterval = const Duration(seconds: 4), this.maxRetries = 3});

  final Duration minInterval;
  final int maxRetries;

  Future<void> _tail = Future.value();
  DateTime? _lastRun;

  Future<T> enqueue<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      final wait = _timeUntilNextSlot();
      if (wait > Duration.zero) {
        await Future<void>.delayed(wait);
      }
      var attempt = 0;
      while (true) {
        attempt++;
        _lastRun = DateTime.now();
        try {
          completer.complete(await task());
          return;
        } catch (error, stack) {
          if (_isRateLimit(error) && attempt <= maxRetries) {
            // Exponential backoff: 8s, 16s, 32s.
            await Future<void>.delayed(Duration(seconds: 4 * (1 << attempt)));
            continue;
          }
          completer.completeError(error, stack);
          return;
        }
      }
    });
    return completer.future;
  }

  Duration _timeUntilNextSlot() {
    final last = _lastRun;
    if (last == null) return Duration.zero;
    final elapsed = DateTime.now().difference(last);
    return elapsed >= minInterval ? Duration.zero : minInterval - elapsed;
  }

  bool _isRateLimit(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 429;
    }
    final message = error.toString().toLowerCase();
    return message.contains('429') ||
        message.contains('rate limit') ||
        message.contains('resource_exhausted') ||
        message.contains('quota');
  }
}
