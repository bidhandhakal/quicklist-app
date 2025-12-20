package com.rimaoli.quicklist.dev

import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryExample(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        try {
            val adView = layoutInflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

            // Set ALL ad asset views before populating them
            adView.headlineView = adView.findViewById(R.id.ad_headline)
            adView.bodyView = adView.findViewById(R.id.ad_body)
            adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
            adView.iconView = adView.findViewById(R.id.ad_app_icon)
            adView.starRatingView = adView.findViewById(R.id.ad_stars)
            adView.advertiserView = adView.findViewById(R.id.ad_advertiser)
            adView.mediaView = adView.findViewById(R.id.ad_media)

            // Populate the ad views with data from NativeAd object
            (adView.headlineView as TextView).text = nativeAd.headline
        
            nativeAd.body?.let {
                (adView.bodyView as TextView).text = it
                adView.bodyView?.visibility = android.view.View.VISIBLE
            }

            nativeAd.callToAction?.let {
                (adView.callToActionView as Button).text = it
                adView.callToActionView?.visibility = android.view.View.VISIBLE
            }

            nativeAd.icon?.let {
                (adView.iconView as ImageView).setImageDrawable(it.drawable)
                adView.iconView?.visibility = android.view.View.VISIBLE
            }

            nativeAd.starRating?.let {
                (adView.starRatingView as RatingBar).rating = it.toFloat()
                adView.starRatingView?.visibility = android.view.View.VISIBLE
            }

            nativeAd.advertiser?.let {
                (adView.advertiserView as TextView).text = it
                adView.advertiserView?.visibility = android.view.View.VISIBLE
            }

            // Set the MediaView with media content
            nativeAd.mediaContent?.let {
                adView.mediaView?.setMediaContent(it)
            }

            // Register the ad view with the native ad object - THIS MUST BE LAST
            adView.setNativeAd(nativeAd)

            return adView
        } catch (e: Exception) {
            android.util.Log.e("NativeAdFactory", "Error creating native ad: ${e.message}")
            throw e
        }
    }
}
