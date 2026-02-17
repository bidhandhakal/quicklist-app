package com.rimaoli.quicklist

import android.content.Intent
import android.view.LayoutInflater
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.quicklist/navigation"
    private var navigationChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        navigationChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Method channel for moving app to background
        navigationChannel!!.setMethodCallHandler { call, result ->
            if (call.method == "moveToBackground") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Check if launched from widget FAB
        handleAddTaskIntent(intent)

        // Register the native ad factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactory",
            NativeAdFactoryExample(LayoutInflater.from(this))
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // Unregister the native ad factory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactory")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAddTaskIntent(intent)
    }

    private fun handleAddTaskIntent(intent: Intent) {
        if (intent.getBooleanExtra("open_add_task", false)) {
            intent.removeExtra("open_add_task")
            // Small delay to let Flutter engine initialize
            window.decorView.postDelayed({
                navigationChannel?.invokeMethod("openAddTask", null)
            }, 500)
        }
    }
}
