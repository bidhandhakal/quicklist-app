import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../services/screen_ad_manager.dart';

/// Native Ad Widget - Reuses ads across navigation (AdMob compliant)
///
/// Uses ScreenAdManager to maintain one ad per screen. The same ad instance
/// is reused across navigation, preventing excessive impressions.
/// Automatically rebuilds when ad finishes loading for instant display.
class NativeAdWidget extends StatefulWidget {
  final String screenId;

  const NativeAdWidget({super.key, required this.screenId});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkAdStatus();
  }

  void _checkAdStatus() {
    if (!AdService.isAdsSupported) return;

    // Check if ad is already loaded
    final isLoaded = ScreenAdManager.instance.isNativeLoaded(widget.screenId);
    if (isLoaded) {
      setState(() => _isLoaded = true);
    } else {
      // Register callback to rebuild when ad loads
      ScreenAdManager.instance.addNativeLoadCallback(
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
    ScreenAdManager.instance.removeNativeLoadCallback(
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

    final ad = ScreenAdManager.instance.getOrCreateNativeAd(widget.screenId);

    if (ad == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 350),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
