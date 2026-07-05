import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob integration: a small banner at the top of the shell and an
/// interstitial after high-value flows (bulk publish). Ads only exist on
/// Android/iOS — every call is a safe no-op elsewhere (desktop/web).
///
/// Uses Google's public TEST ad unit IDs; swap in real ones before a
/// store release.
class AdsService {
  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool _initialized = false;
  InterstitialAd? _pendingInterstitial;

  Future<void> initialize() async {
    if (!isSupported || _initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    _preloadInterstitial();
  }

  void _preloadInterstitial() {
    if (!isSupported) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _pendingInterstitial = ad,
        onAdFailedToLoad: (_) => _pendingInterstitial = null,
      ),
    );
  }

  /// Shows the preloaded interstitial once (called after e.g. a successful
  /// bulk publish) and immediately begins preloading the next one.
  void maybeShowInterstitial() {
    final ad = _pendingInterstitial;
    if (ad == null) return;
    _pendingInterstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _preloadInterstitial();
      },
    );
    ad.show();
  }
}

final adsServiceProvider = Provider<AdsService>((ref) => AdsService());
