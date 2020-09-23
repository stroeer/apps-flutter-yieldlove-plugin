package com.example.AppsFlutterYieldloveSDK

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAd
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAdListener
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAdView
import com.yieldlove.adIntegration.AdUnit.YieldloveAdUnit

object InterstitialHolder {

    var interstitialView: YieldloveInterstitialAdView? = null
    var activity: Activity? = null
    var wasAlreadyShown = false
    var loadError = false

    fun delegateMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadInterstitialAd" -> {
                if (loadError || wasAlreadyShown) {
                    result.success(false)
                    return
                }
                val adUnitId = call.argument<String>("ad_unit_id")
                val adUnit = YieldloveAdUnit(adUnitId, "23935")
                YieldloveInterstitialAd(adUnit, activity, object : YieldloveInterstitialAdListener {
                    override fun onAdInit(interstitial: YieldloveInterstitialAdView?) {
                        interstitialView = interstitial
                        interstitialView?.show()
                    }

                    override fun onAdLeftApplication(interstitial: YieldloveInterstitialAdView?) {
                        // ;
                        result.success(true)
                    }

                    override fun onAdRequestBuild(): PublisherAdRequest.Builder? {
                        // TODO?
                        //if(npa == true) {
                        //    val extras = Bundle()
                        //    extras.putString("npa", "1")
                        //    adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                        //}
                        return null
                    }

                    override fun onAdFailedToLoad(interstitial: YieldloveInterstitialAdView?, errorCode: Int) {
                        loadError = true
                        result.success(false)
                    }

                    override fun onAdLoaded(interstitial: YieldloveInterstitialAdView?) {
                        loadError = false
                        result.success(true)
                    }

                    override fun onAdOpened(interstitial: YieldloveInterstitialAdView?) {
                        result.success(true)
                    }

                    override fun onAdClosed(interstitial: YieldloveInterstitialAdView?) {
                        wasAlreadyShown = true
                        result.success(true)
                    }
                })
            }
            else -> result.success(false)
        }

    }

}
