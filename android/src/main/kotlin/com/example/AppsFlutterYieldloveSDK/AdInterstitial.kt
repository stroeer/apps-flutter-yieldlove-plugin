package com.example.AppsFlutterYieldloveSDK

import android.annotation.SuppressLint
import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import com.google.android.gms.ads.admanager.AdManagerAdView
import com.google.android.gms.ads.admanager.AdManagerAdRequest
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAd
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAdListener
import com.yieldlove.adIntegration.AdFormats.YieldloveInterstitialAdView
import com.yieldlove.adIntegration.AdUnit.YieldloveAdUnit
import com.yieldlove.adIntegration.exceptions.YieldloveException

@SuppressLint("StaticFieldLeak")
object InterstitialHolder {

    var activity: Activity? = null

    fun delegateMethodCall(call: MethodCall, result: MethodChannel.Result, channel: MethodChannel) {
        when (call.method) {
            "loadInterstitialAd" -> {
                if (activity == null) {
                    val map: HashMap<String, Any> = hashMapOf<String, Any>(
                            "errorMessage" to "Activity was null"
                    )
                    channel?.invokeMethod("showInterstitialError", map)
                    result.success(false)
                    return
                }
                val adUnitId = call.argument<String>("ad_unit_id")
                //val adUnit = YieldloveAdUnit(adUnitId, "23935")
                val interstitialAd = YieldloveInterstitialAd(activity)
                interstitialAd.load(adUnitId, object : YieldloveInterstitialAdListener {
                    //override fun onAdInit(interstitial: YieldloveInterstitialAdView?) {
                    //    interstitialView = interstitial
                    //    interstitialView?.show()
                    //}

                    //override fun onAdLeftApplication(interstitial: YieldloveInterstitialAdView?) {
                    //    result.success(true)
                    //}

                    override fun onAdRequestBuild(): AdManagerAdRequest.Builder? {
                        return null
                    }

                    override fun onAdFailedToLoad(interstitial: YieldloveInterstitialAdView?, exception: YieldloveException?) {
                        val map: HashMap<String, Any> = hashMapOf<String, Any>(
                                "errorMessage" to exception.toString()
                        )
                        channel?.invokeMethod("showInterstitialError", map)
                        result.success(false)
                    }

                    override fun onAdLoaded(interstitial: YieldloveInterstitialAdView?) {
                        interstitial?.show()
                        channel?.invokeMethod("didShowInterstitial", null)
                        result.success(true)
                    }

                    //override fun onAdOpened(interstitial: YieldloveInterstitialAdView?) { // deprecated in v5.0.0
                    //    result.success(true)
                    //}

                    //override fun onAdClosed(interstitial: YieldloveInterstitialAdView?) { // deprecated in v5.0.0
                    //    wasAlreadyShown = true
                    //    result.success(true)
                    //}
                })
            }
            else -> result.success(false)
        }

    }

}
