import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Manages Interstitial Ads for the app
class InterstitialAdManager {
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  /// Load an interstitial ad
  Future<void> loadAd() async {
    // Only load ads on Android
    if (!AdService.isAdsSupported) {
      debugPrint('InterstitialAd: Ads not supported on this platform');
      return;
    }

    // Don't load if already loaded
    if (_isAdLoaded && _interstitialAd != null) {
      debugPrint('InterstitialAd: Ad already loaded');
      return;
    }

    debugPrint('InterstitialAd: Loading ad (attempt ${_loadAttempts + 1})...');
    await InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd: Ad loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _loadAttempts = 0;

          // Set up callbacks
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('InterstitialAd: Ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAd: Ad dismissed full screen content');
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Load a new ad for next time
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                'InterstitialAd: Failed to show full screen content: ${error.message}',
              );
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Load a new ad
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd: Failed to load ad: ${error.message}');
          _loadAttempts++;
          _interstitialAd = null;
          _isAdLoaded = false;

          // Retry loading if under max attempts
          if (_loadAttempts < _maxLoadAttempts) {
            debugPrint('InterstitialAd: Retrying in 5 seconds...');
            Future.delayed(const Duration(seconds: 5), loadAd);
          } else {
            debugPrint(
              'InterstitialAd: Max load attempts reached. Resetting counter.',
            );
            _loadAttempts = 0;
          }
        },
      ),
    );
  }

  /// Show the interstitial ad if available
  void showAd() {
    // Only show ads on Android
    if (!AdService.isAdsSupported) {
      debugPrint('InterstitialAd: Ads not supported on this platform');
      return;
    }

    if (!_isAdLoaded || _interstitialAd == null) {
      debugPrint('InterstitialAd: Ad not loaded, cannot show');
      // Try to load for next time
      loadAd();
      return;
    }

    debugPrint('InterstitialAd: Showing ad');
    _interstitialAd!.show();
  }

  /// Check if an ad is loaded and ready to show
  bool get isAdReady => _isAdLoaded && _interstitialAd != null;

  /// Dispose the current ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
