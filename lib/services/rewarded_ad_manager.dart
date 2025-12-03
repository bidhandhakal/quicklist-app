import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Manages Rewarded Ads for the app
class RewardedAdManager {
  static final RewardedAdManager _instance = RewardedAdManager._internal();
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  /// Load a rewarded ad
  Future<void> loadAd() async {
    // Only load ads on Android
    if (!AdService.isAdsSupported) {
      debugPrint('RewardedAd: Ads not supported on this platform');
      return;
    }

    // Don't load if already loaded
    if (_isAdLoaded && _rewardedAd != null) {
      debugPrint('RewardedAd: Ad already loaded');
      return;
    }

    debugPrint('RewardedAd: Loading ad (attempt ${_loadAttempts + 1})...');
    await RewardedAd.load(
      adUnitId: AdService.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd: Ad loaded successfully');
          _rewardedAd = ad;
          _isAdLoaded = true;
          _loadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd: Failed to load ad: ${error.message}');
          _loadAttempts++;
          _rewardedAd = null;
          _isAdLoaded = false;

          // Retry loading if under max attempts
          if (_loadAttempts < _maxLoadAttempts) {
            debugPrint('RewardedAd: Retrying in 5 seconds...');
            Future.delayed(const Duration(seconds: 5), loadAd);
          } else {
            debugPrint(
              'RewardedAd: Max load attempts reached. Resetting counter.',
            );
            _loadAttempts = 0;
          }
        },
      ),
    );
  }

  /// Show the rewarded ad with a callback when the user earns the reward
  Future<bool> showAd() async {
    // Only show ads on Android
    if (!AdService.isAdsSupported) {
      debugPrint('RewardedAd: Ads not supported on this platform');
      return false;
    }

    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('RewardedAd: Ad not loaded, cannot show');
      // Try to load for next time
      loadAd();
      return false;
    }

    debugPrint('RewardedAd: Showing ad');

    // Use a Completer to wait for the ad to complete
    final completer = Completer<bool>();
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardedAd: Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardedAd: Ad dismissed full screen content');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        // Load a new ad for next time
        loadAd();
        // Complete with the reward status
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'RewardedAd: Failed to show full screen content: ${error.message}',
        );
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        // Load a new ad
        loadAd();
        // Complete with false
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(
          'RewardedAd: User earned reward: ${reward.amount} ${reward.type}',
        );
        rewardEarned = true;
      },
    );

    // Wait for the ad to be dismissed
    return completer.future;
  }

  /// Check if an ad is loaded and ready to show
  bool get isAdReady => _isAdLoaded && _rewardedAd != null;

  /// Dispose the current ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
