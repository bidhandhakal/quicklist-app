import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Manages ads per screen to prevent reload on navigation
///
/// This singleton maintains one ad instance per screen ID. When navigating
/// away and back to a screen, the same ad is reused (AdMob compliant).
/// Ads are only refreshed after 60 seconds, preventing excessive impressions.
class ScreenAdManager {
  static final ScreenAdManager _instance = ScreenAdManager._internal();
  static ScreenAdManager get instance => _instance;

  ScreenAdManager._internal();

  // Storage for banner ads
  final Map<String, BannerAd> _bannerAds = {};
  final Map<String, DateTime> _bannerLoadTimes = {};
  final Map<String, bool> _bannerLoadState = {};

  // Storage for native ads
  final Map<String, NativeAd> _nativeAds = {};
  final Map<String, DateTime> _nativeLoadTimes = {};
  final Map<String, bool> _nativeLoadState = {};
  final Map<String, Timer> _nativeAdTimers = {};

  // Callbacks for ad load notifications (for instant widget updates)
  final Map<String, List<VoidCallback>> _bannerLoadCallbacks = {};
  final Map<String, List<VoidCallback>> _nativeLoadCallbacks = {};

  // Refresh interval (60 seconds per AdMob best practices)
  static const Duration _refreshInterval = Duration(seconds: 60);

  /// Add callback to be notified when banner ad loads
  void addBannerLoadCallback(String screenId, VoidCallback callback) {
    _bannerLoadCallbacks.putIfAbsent(screenId, () => []).add(callback);
  }

  /// Remove banner load callback
  void removeBannerLoadCallback(String screenId, VoidCallback callback) {
    _bannerLoadCallbacks[screenId]?.remove(callback);
  }

  /// Add callback to be notified when native ad loads
  void addNativeLoadCallback(String screenId, VoidCallback callback) {
    _nativeLoadCallbacks.putIfAbsent(screenId, () => []).add(callback);
  }

  /// Remove native load callback
  void removeNativeLoadCallback(String screenId, VoidCallback callback) {
    _nativeLoadCallbacks[screenId]?.remove(callback);
  }

  /// Notify all listeners that banner ad loaded
  void _notifyBannerLoaded(String screenId) {
    final callbacks = _bannerLoadCallbacks[screenId];
    if (callbacks != null) {
      for (final callback in List.from(callbacks)) {
        callback();
      }
    }
  }

  /// Notify all listeners that native ad loaded
  void _notifyNativeLoaded(String screenId) {
    final callbacks = _nativeLoadCallbacks[screenId];
    if (callbacks != null) {
      for (final callback in List.from(callbacks)) {
        callback();
      }
    }
  }

  /// Preload banner ad for a screen (call during app init for instant display)
  void preloadBannerAd(String screenId) {
    if (!AdService.isAdsSupported) return;
    if (_bannerAds.containsKey(screenId)) return; // Already loaded

    debugPrint('ScreenAdManager: PRELOADING banner for $screenId');
    _createBannerAd(screenId);
  }

  /// Preload native ad for a screen (call during app init for instant display)
  void preloadNativeAd(String screenId) {
    if (!AdService.isAdsSupported) return;
    if (_nativeAds.containsKey(screenId)) return; // Already loaded

    debugPrint('ScreenAdManager: PRELOADING native ad for $screenId');
    _createNativeAd(screenId);
  }

  /// Get or create banner ad - initializes only once per screen
  BannerAd? getOrCreateBannerAd(String screenId) {
    if (!AdService.isAdsSupported) return null;

    // If ad exists and is fresh, return it
    if (_bannerAds.containsKey(screenId) && _isFreshBannerAd(screenId)) {
      return _bannerAds[screenId];
    }

    // If ad is loading, return the current instance
    if (_bannerAds.containsKey(screenId) &&
        _bannerLoadState[screenId] == false) {
      return _bannerAds[screenId];
    }

    // Create new ad
    debugPrint('ScreenAdManager: Creating NEW banner ad for $screenId');
    _createBannerAd(screenId);
    return _bannerAds[screenId];
  }

  /// Get or create native ad - initializes only once per screen
  NativeAd? getOrCreateNativeAd(String screenId) {
    if (!AdService.isAdsSupported) return null;

    // If ad exists and is fresh, return it
    if (_nativeAds.containsKey(screenId) && _isFreshNativeAd(screenId)) {
      return _nativeAds[screenId];
    }

    // If ad is loading, return the current instance
    if (_nativeAds.containsKey(screenId) &&
        _nativeLoadState[screenId] == false) {
      return _nativeAds[screenId];
    }

    // Create new ad
    debugPrint('ScreenAdManager: Creating NEW native ad for $screenId');
    _createNativeAd(screenId);
    return _nativeAds[screenId];
  }

  /// Internal method to create banner ad
  void _createBannerAd(String screenId) {
    // Dispose old ad if it exists
    _bannerAds[screenId]?.dispose();

    // Create new ad with optimized request
    final bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(
        httpTimeoutMillis: 10000, // 10 second timeout for faster loading
        keywords: ['productivity', 'tasks', 'todo'], // Better ad targeting
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('ScreenAdManager: ✅ Banner LOADED for $screenId');
          _bannerLoadState[screenId] = true;
          _bannerLoadTimes[screenId] = DateTime.now();
          // Notify all widgets waiting for this ad
          _notifyBannerLoaded(screenId);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'ScreenAdManager: ❌ Banner FAILED for $screenId: ${error.message}',
          );
          _bannerLoadState[screenId] = false;
          _bannerAds.remove(screenId);
          _bannerLoadTimes.remove(screenId);
          ad.dispose();
        },
      ),
    );

    _bannerAds[screenId] = bannerAd;
    _bannerLoadState[screenId] = false;
    bannerAd.load();
  }

  /// Internal method to create native ad
  void _createNativeAd(String screenId) {
    // Dispose old ad if it exists
    _nativeAds[screenId]?.dispose();

    // Create new ad with optimized request
    final nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(
        httpTimeoutMillis: 10000, // 10 second timeout for faster loading
        keywords: ['productivity', 'tasks', 'todo'], // Better ad targeting
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('ScreenAdManager: ✅ Native ad LOADED for $screenId');
          _nativeLoadState[screenId] = true;
          _nativeLoadTimes[screenId] = DateTime.now();
          // Notify all widgets waiting for this ad
          _notifyNativeLoaded(screenId);

          // Start auto-refresh timer for this native ad
          _startNativeAdRefreshTimer(screenId);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'ScreenAdManager: ❌ Native ad FAILED for $screenId: ${error.message}',
          );
          _nativeLoadState[screenId] = false;
          _nativeAds.remove(screenId);
          _nativeLoadTimes.remove(screenId);
          _nativeAdTimers[screenId]?.cancel();
          _nativeAdTimers.remove(screenId);
          ad.dispose();
        },
      ),
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
      ),
      factoryId: 'adFactory',
    );

    _nativeAds[screenId] = nativeAd;
    _nativeLoadState[screenId] = false;
    nativeAd.load();
  }

  /// Get or create banner ad for screen
  BannerAd? getBannerAd(
    String screenId, {
    required VoidCallback onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (!AdService.isAdsSupported) return null;

    // Check if we have a fresh ad
    if (_bannerAds.containsKey(screenId) && _isFreshBannerAd(screenId)) {
      debugPrint('ScreenAdManager: Reusing existing banner for $screenId');
      // Ad is already loaded, trigger callback immediately
      if (_bannerLoadState[screenId] == true) {
        onAdLoaded();
      }
      return _bannerAds[screenId];
    }

    // Dispose old ad if it exists
    _bannerAds[screenId]?.dispose();

    debugPrint('ScreenAdManager: Creating new banner ad for $screenId');

    // Create new ad
    final bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('ScreenAdManager: Banner loaded for $screenId');
          _bannerLoadState[screenId] = true;
          _bannerLoadTimes[screenId] = DateTime.now();
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'ScreenAdManager: Banner failed for $screenId: ${error.message}',
          );
          _bannerLoadState[screenId] = false;
          _bannerAds.remove(screenId);
          _bannerLoadTimes.remove(screenId);
          onAdFailedToLoad(ad, error);
          ad.dispose();
        },
      ),
    );

    _bannerAds[screenId] = bannerAd;
    _bannerLoadState[screenId] = false;

    // Load the ad
    bannerAd.load();

    return bannerAd;
  }

  /// Get or create native ad for screen
  NativeAd? getNativeAd(
    String screenId, {
    required VoidCallback onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (!AdService.isAdsSupported) return null;

    // Check if we have a fresh ad
    if (_nativeAds.containsKey(screenId) && _isFreshNativeAd(screenId)) {
      debugPrint('ScreenAdManager: Reusing existing native ad for $screenId');
      // Ad is already loaded, trigger callback immediately
      if (_nativeLoadState[screenId] == true) {
        onAdLoaded();
      }
      return _nativeAds[screenId];
    }

    // Dispose old ad if it exists
    _nativeAds[screenId]?.dispose();

    debugPrint('ScreenAdManager: Creating new native ad for $screenId');

    // Create new ad
    final nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('ScreenAdManager: Native ad loaded for $screenId');
          _nativeLoadState[screenId] = true;
          _nativeLoadTimes[screenId] = DateTime.now();
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'ScreenAdManager: Native ad failed for $screenId: ${error.message}',
          );
          _nativeLoadState[screenId] = false;
          _nativeAds.remove(screenId);
          _nativeLoadTimes.remove(screenId);
          onAdFailedToLoad(ad, error);
          ad.dispose();
        },
      ),
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
      ),
      factoryId: 'adFactory',
    );

    _nativeAds[screenId] = nativeAd;
    _nativeLoadState[screenId] = false;

    // Load the ad
    nativeAd.load();

    return nativeAd;
  }

  /// Check if banner ad is fresh (loaded and within refresh interval)
  bool _isFreshBannerAd(String screenId) {
    if (!_bannerLoadState.containsKey(screenId) ||
        _bannerLoadState[screenId] != true) {
      return false;
    }

    final loadTime = _bannerLoadTimes[screenId];
    if (loadTime == null) return false;

    final age = DateTime.now().difference(loadTime);
    return age < _refreshInterval;
  }

  /// Check if native ad is fresh (loaded and within refresh interval)
  bool _isFreshNativeAd(String screenId) {
    if (!_nativeLoadState.containsKey(screenId) ||
        _nativeLoadState[screenId] != true) {
      return false;
    }

    final loadTime = _nativeLoadTimes[screenId];
    if (loadTime == null) return false;

    final age = DateTime.now().difference(loadTime);
    return age < _refreshInterval;
  }

  /// Check if banner ad is loaded
  bool isBannerLoaded(String screenId) {
    return _bannerLoadState[screenId] == true;
  }

  /// Check if native ad is loaded
  bool isNativeLoaded(String screenId) {
    return _nativeLoadState[screenId] == true;
  }

  /// Dispose specific banner ad
  void disposeBannerAd(String screenId) {
    debugPrint('ScreenAdManager: Disposing banner for $screenId');
    _bannerAds[screenId]?.dispose();
    _bannerAds.remove(screenId);
    _bannerLoadTimes.remove(screenId);
    _bannerLoadState.remove(screenId);
  }

  /// Dispose specific native ad
  void disposeNativeAd(String screenId) {
    debugPrint('ScreenAdManager: Disposing native ad for $screenId');
    _nativeAds[screenId]?.dispose();
    _nativeAds.remove(screenId);
    _nativeLoadTimes.remove(screenId);
    _nativeLoadState.remove(screenId);
  }

  /// Dispose all ads (call on app termination)
  void disposeAll() {
    debugPrint('ScreenAdManager: Disposing all ads');

    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    _bannerAds.clear();
    _bannerLoadTimes.clear();
    _bannerLoadState.clear();

    for (final ad in _nativeAds.values) {
      ad.dispose();
    }
    for (final timer in _nativeAdTimers.values) {
      timer.cancel();
    }
    _nativeAds.clear();
    _nativeLoadTimes.clear();
    _nativeLoadState.clear();
    _nativeAdTimers.clear();
  }

  /// Start auto-refresh timer for native ad (refreshes every 60 seconds)
  void _startNativeAdRefreshTimer(String screenId) {
    // Cancel existing timer if any
    _nativeAdTimers[screenId]?.cancel();

    // Create new timer
    _nativeAdTimers[screenId] = Timer.periodic(_refreshInterval, (timer) {
      debugPrint('ScreenAdManager: 🔄 Auto-refreshing native ad for $screenId');
      _refreshNativeAd(screenId);
    });
  }

  /// Refresh a native ad
  void _refreshNativeAd(String screenId) {
    // Cancel timer first
    _nativeAdTimers[screenId]?.cancel();
    _nativeAdTimers.remove(screenId);

    // Recreate the ad (this will start a new timer when it loads)
    _createNativeAd(screenId);
  }
}
