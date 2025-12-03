import 'package:flutter/material.dart';
import 'app_open_ad_manager.dart';

/// Listens to app lifecycle events and shows app open ads when appropriate
class AppLifecycleReactor with WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  /// Initialize the lifecycle observer
  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stop listening to app lifecycle events
  void stopListening() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleReactor: App state changed to $state');

    // Show ad when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('AppLifecycleReactor: App resumed, showing ad if available');
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
