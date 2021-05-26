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

    var interstitialView: YieldloveInterstitialAdView? = null
    var activity: Activity? = null
    var wasAlreadyShown = false
    var loadError = false

    fun delegateMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadInterstitialAd" -> {
                if (loadError || wasAlreadyShown || activity == null) {
                    result.success(false)
                    return
                }
                val adUnitId = call.argument<String>("ad_unit_id")
                val adUnit = YieldloveAdUnit(adUnitId, "23935")
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
                        loadError = true
                        result.success(false)
                    }

                    override fun onAdLoaded(interstitial: YieldloveInterstitialAdView?) {
                        loadError = false
                        interstitialView = interstitial // before GAM 20 introduction: called in onAdInit()
                        interstitialView?.show() // before GAM 20 introduction: called in onAdInit()
                        wasAlreadyShown = true
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
