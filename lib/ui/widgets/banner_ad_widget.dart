import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../services/screen_ad_manager.dart';

/// Banner Ad Widget - Reuses ads across navigation (AdMob compliant)
///
/// Uses ScreenAdManager to maintain one ad per screen. The same ad instance
/// is reused across navigation, preventing excessive impressions.
/// Automatically rebuilds when ad finishes loading for instant display.
class BannerAdWidget extends StatefulWidget {
  final String screenId;

  const BannerAdWidget({super.key, required this.screenId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkAdStatus();
  }

  void _checkAdStatus() {
    if (!AdService.isAdsSupported) return;

    // Check if ad is already loaded
    final isLoaded = ScreenAdManager.instance.isBannerLoaded(widget.screenId);
    if (isLoaded) {
      setState(() => _isLoaded = true);
    } else {
      // Register callback to rebuild when ad loads
      ScreenAdManager.instance.addBannerLoadCallback(
        widget.screenId,
        _onAdLoaded,
      );
    }
  }

  void _onAdLoaded() {
    if (mounted) {
      setState(() => _isLoaded = true);
    }
  }

  @override
  void dispose() {
    ScreenAdManager.instance.removeBannerLoadCallback(
      widget.screenId,
      _onAdLoaded,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isAdsSupported) {
      return const SizedBox.shrink();
    }

    final ad = ScreenAdManager.instance.getOrCreateBannerAd(widget.screenId);

    if (ad == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
