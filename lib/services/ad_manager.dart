import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Centralized ad manager that prevents unnecessary ad reloads
/// and minimizes impressions per user while maintaining AdMob compliance
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Cache of banner ads per screen
  final Map<String, BannerAdController> _bannerControllers = {};

  // Cache of native ads per screen
  final Map<String, NativeAdController> _nativeControllers = {};

  /// Get or create a banner ad controller for a specific screen
  BannerAdController getBannerController(String screenId) {
    if (!_bannerControllers.containsKey(screenId)) {
      _bannerControllers[screenId] = BannerAdController(screenId);
    }
    return _bannerControllers[screenId]!;
  }

  /// Get or create a native ad controller for a specific screen
  NativeAdController getNativeController(String screenId) {
    if (!_nativeControllers.containsKey(screenId)) {
      _nativeControllers[screenId] = NativeAdController(screenId);
    }
    return _nativeControllers[screenId]!;
  }

  /// Dispose a specific banner controller
  void disposeBannerController(String screenId) {
    _bannerControllers[screenId]?.dispose();
    _bannerControllers.remove(screenId);
  }

  /// Dispose a specific native controller
  void disposeNativeController(String screenId) {
    _nativeControllers[screenId]?.dispose();
    _nativeControllers.remove(screenId);
  }

  /// Dispose all ads (call when app is closing)
  void disposeAll() {
    for (var controller in _bannerControllers.values) {
      controller.dispose();
    }
    for (var controller in _nativeControllers.values) {
      controller.dispose();
    }
    _bannerControllers.clear();
    _nativeControllers.clear();
  }
}

/// Controller for managing banner ads with optional auto-refresh
class BannerAdController {
  final String screenId;
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;
  Timer? _refreshTimer;

  // Refresh interval: 60-120 seconds (configurable)
  final Duration refreshInterval;
  final bool enableAutoRefresh;

  // Listeners for ad state changes
  final List<VoidCallback> _listeners = [];

  BannerAdController(
    this.screenId, {
    this.refreshInterval = const Duration(seconds: 60),
    this.enableAutoRefresh = true,
  });

  /// Current ad instance
  BannerAd? get ad => _bannerAd;

  /// Whether the ad is loaded and ready to display
  bool get isLoaded => _isLoaded && !_isDisposed;

  /// Whether the ad is currently loading
  bool get isLoading => _isLoading;

  /// Add a listener for ad state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  /// Load the banner ad (only loads once if already loaded)
  Future<void> loadAd() async {
    if (_isDisposed || !AdService.isAdsSupported) return;

    // Don't reload if already loaded or loading
    if (_isLoaded || _isLoading) {
      debugPrint(
        'BannerAdController[$screenId]: Ad already loaded/loading, skipping',
      );
      return;
    }

    _isLoading = true;
    debugPrint('BannerAdController[$screenId]: Loading ad...');

    try {
      _bannerAd = AdService().createBannerAd(
        onAdLoaded: (ad) {
          if (!_isDisposed) {
            debugPrint('BannerAdController[$screenId]: Ad loaded successfully');
            _isLoaded = true;
            _isLoading = false;
            _notifyListeners();

            // Start auto-refresh timer if enabled
            if (enableAutoRefresh) {
              _startRefreshTimer();
            }
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'BannerAdController[$screenId]: Ad failed to load: ${error.message}',
          );
          if (!_isDisposed) {
            ad.dispose();
            _isLoaded = false;
            _isLoading = false;
            _notifyListeners();
          }
        },
      );

      await _bannerAd?.load();
    } catch (e) {
      debugPrint('BannerAdController[$screenId]: Error loading ad: $e');
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Start the auto-refresh timer
  void _startRefreshTimer() {
    _refreshTimer?.cancel();

    if (!enableAutoRefresh || _isDisposed) return;

    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      if (!_isDisposed && AdService.isAdsSupported) {
        debugPrint(
          'BannerAdController[$screenId]: Auto-refreshing ad after $refreshInterval',
        );
        _refreshAd();
      }
    });
  }

  /// Refresh the ad (creates a new impression)
  Future<void> _refreshAd() async {
    if (_isDisposed) return;

    // Dispose old ad
    _bannerAd?.dispose();
    _isLoaded = false;
    _isLoading = false;

    // Load new ad
    await loadAd();
  }

  /// Stop auto-refresh timer
  void pauseRefresh() {
    _refreshTimer?.cancel();
    debugPrint('BannerAdController[$screenId]: Refresh paused');
  }

  /// Resume auto-refresh timer
  void resumeRefresh() {
    if (enableAutoRefresh && _isLoaded && !_isDisposed) {
      _startRefreshTimer();
      debugPrint('BannerAdController[$screenId]: Refresh resumed');
    }
  }

  /// Mark widget as attached to the tree
  void attachWidget() {
    // Widget is now in the tree
  }

  /// Mark widget as detached from the tree
  void detachWidget() {
    // Widget has been removed from the tree
  }

  /// Dispose the controller and its ad
  void dispose() {
    if (_isDisposed) return;

    debugPrint('BannerAdController[$screenId]: Disposing');
    _isDisposed = true;
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    _listeners.clear();
  }
}

/// Controller for managing native ads (no auto-refresh to minimize impressions)
class NativeAdController {
  final String screenId;
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;

  // Listeners for ad state changes
  final List<VoidCallback> _listeners = [];

  NativeAdController(this.screenId);

  /// Current ad instance
  NativeAd? get ad => _nativeAd;

  /// Whether the ad is loaded and ready to display
  bool get isLoaded => _isLoaded && !_isDisposed;

  /// Whether the ad is currently loading
  bool get isLoading => _isLoading;

  /// Add a listener for ad state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  /// Load the native ad (only loads once if already loaded)
  Future<void> loadAd() async {
    if (_isDisposed || !AdService.isAdsSupported) return;

    // Don't reload if already loaded or loading
    if (_isLoaded || _isLoading) {
      debugPrint(
        'NativeAdController[$screenId]: Ad already loaded/loading, skipping',
      );
      return;
    }

    _isLoading = true;
    debugPrint('NativeAdController[$screenId]: Loading ad...');

    try {
      _nativeAd = NativeAd(
        adUnitId: AdService.nativeAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!_isDisposed) {
              debugPrint(
                'NativeAdController[$screenId]: Ad loaded successfully',
              );
              _isLoaded = true;
              _isLoading = false;
              _notifyListeners();
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
              'NativeAdController[$screenId]: Ad failed to load: ${error.message}',
            );
            if (!_isDisposed) {
              ad.dispose();
              _isLoaded = false;
              _isLoading = false;
              _nativeAd = null;
              _notifyListeners();
            }
          },
        ),
        nativeAdOptions: NativeAdOptions(
          // AdMob policy: Clearly indicate sponsored content
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        ),
        factoryId: 'adFactory', // Must match platform implementation
      );

      await _nativeAd?.load();
    } catch (e) {
      debugPrint('NativeAdController[$screenId]: Error loading ad: $e');
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Dispose the controller and its ad
  void dispose() {
    if (_isDisposed) return;

    debugPrint('NativeAdController[$screenId]: Disposing');
    _isDisposed = true;
    _nativeAd?.dispose();
    _listeners.clear();
  }
}
