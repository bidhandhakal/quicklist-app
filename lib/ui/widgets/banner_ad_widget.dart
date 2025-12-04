import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Timer? _refreshTimer;

  // Refresh interval: 90 seconds (1.5 minutes)
  static const Duration _refreshInterval = Duration(seconds: 90);

  @override
  void initState() {
    super.initState();
    debugPrint('BannerAdWidget: initState called');
    debugPrint('BannerAdWidget: isAdsSupported = ${AdService.isAdsSupported}');
    // Only load ads on Android
    if (AdService.isAdsSupported) {
      debugPrint('BannerAdWidget: Loading ad...');
      _loadAd();
      _startRefreshTimer();
    } else {
      debugPrint('BannerAdWidget: Ads not supported on this platform');
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted && AdService.isAdsSupported) {
        debugPrint('BannerAdWidget: Refreshing ad after $_refreshInterval');
        _loadAd();
      }
    });
  }

  void _loadAd() {
    try {
      // Dispose old ad before loading new one
      _bannerAd?.dispose();

      _bannerAd = AdService().createBannerAd(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded successfully!');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );

      debugPrint('BannerAdWidget: Calling load() on banner ad');
      _bannerAd?.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show ads on Android
    if (!AdService.isAdsSupported || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
