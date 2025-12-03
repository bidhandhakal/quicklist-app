import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Android Banner Ad Unit ID - Using test ad ID
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Google test ad ID
  // Production: 'ca-app-pub-5567758691495974/1779261733'

  // Android App Open Ad Unit ID - Using test ad ID
  static const String _androidAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921'; // Google test ad ID
  // Production: 'ca-app-pub-5567758691495974/1370716550'

  // Android Interstitial Ad Unit ID - Using test ad ID
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Google test ad ID
  // Production: Add your production interstitial ad unit ID here

  // Android Rewarded Ad Unit ID - Using test ad ID
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Google test ad ID
  // Production: Add your production rewarded ad unit ID here

  static String get bannerAdUnitId => _androidBannerAdUnitId;
  static String get appOpenAdUnitId => _androidAppOpenAdUnitId;
  static String get interstitialAdUnitId => _androidInterstitialAdUnitId;
  static String get rewardedAdUnitId => _androidRewardedAdUnitId;

  // Initialize Mobile Ads SDK - Only for Android
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await MobileAds.instance.initialize();
    }
  }

  // Check if ads are supported on current platform
  static bool get isAdsSupported => Platform.isAndroid;

  // Create a banner ad - Only for Android
  BannerAd? createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (!Platform.isAndroid) {
      return null;
    }

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('BannerAd opened.'),
        onAdClosed: (ad) => debugPrint('BannerAd closed.'),
      ),
    );
  }
}
