import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Android Banner Ad Unit ID - Test
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Android App Open Ad Unit ID - Test
  static const String _androidAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  // Android Interstitial Ad Unit ID - Test
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Android Rewarded Ad Unit ID - Test
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Android Native Ad Unit ID - Test
  static const String _androidNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';

  static String get bannerAdUnitId => _androidBannerAdUnitId;
  static String get appOpenAdUnitId => _androidAppOpenAdUnitId;
  static String get interstitialAdUnitId => _androidInterstitialAdUnitId;
  static String get rewardedAdUnitId => _androidRewardedAdUnitId;
  static String get nativeAdUnitId => _androidNativeAdUnitId;

  // Initialize Mobile Ads SDK - Only for Android
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await MobileAds.instance.initialize();

      // Configure request settings for faster ad loading
      final requestConfiguration = RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        maxAdContentRating: MaxAdContentRating.pg,
      );

      MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      if (kDebugMode) {
        print('AdService: MobileAds initialized with optimized configuration');
      }
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
