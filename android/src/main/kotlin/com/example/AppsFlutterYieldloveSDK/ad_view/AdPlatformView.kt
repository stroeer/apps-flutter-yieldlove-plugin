package com.example.AppsFlutterYieldloveSDK

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.util.Log
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import java.util.*


class AdPlatformView internal constructor(context: Context?,
                                          messenger: BinaryMessenger?,
                                          val id: Int,
                                          params: Map<String, Any>?,
                                          containerView: View?)
    : PlatformView, MethodCallHandler {

    companion object {
        var activity: Activity? = null
    }

    private var adView: AdView? = null
    private var methodChannel: MethodChannel? = null
    private var platformThreadHandler: Handler? = null

    init {
        var adId: String = ""
        var adKeyword: String? = null
        var adContentUrl: String? = null
        var adIsRelease: Boolean = false
        var useTestAds: Boolean = false
        var customTargeting: Map<String, String>? = null

        if (params?.containsKey("ad_id") == true) {
            adId = params["ad_id"] as String
            adKeyword = params["ad_keyword"] as String?
            adContentUrl = params["ad_content_url"] as String?
            adIsRelease = params["ad_is_release"] as Boolean
            useTestAds = params["use_test_ads"] as Boolean
            customTargeting = params["custom_targeting"] as Map<String, String>? ?: mapOf()
            Log.v("app-platform-view", "Ad(id=${adId}, " +
                    "adKeyword=${adKeyword}, " +
                    "contentUrl=${adContentUrl}, " +
                    "adIsRelease=${adIsRelease}, " +
                    "adIsTest=${useTestAds}, " +
                    "customTargeting=${customTargeting}"
            )
        }

        adView = createAdView(
                context,
                Ad(adId, adKeyword, customTargeting),
                adContentUrl,
                adIsRelease,
                useTestAds
        )

        platformThreadHandler = Handler(context!!.mainLooper)
        methodChannel = MethodChannel(messenger, "de.stroeer.plugins/adview_$id")
        methodChannel?.setMethodCallHandler(this)
    }

    private fun createAdView(context1: Context?,
                             ad: Ad,
                             contentUrl: String?,
                             isRelease: Boolean = false,
                             useTestAds: Boolean = false
    ): AdView? {
        if (context1 == null) return null
        return AdView(
                context = context1,
                visible = View.VISIBLE,
                backgroundColorRes = R.color.moduleBackground
        ).apply {
            this.contentUrl = contentUrl
            this.isRelease = isRelease
            this.visibility = View.GONE
            this.adSizeCallback = { screenHeight, adHeight ->
                methodChannel?.invokeMethod("adSizeDetermined", argumentsMap("screenHeight", screenHeight ?: 0, "adHeight", adHeight ?: 0))
            }
            this.adEventListener = { event ->
                when (event) {
                    is YieldAdEvent.OnAdFailedToLoad -> methodChannel?.invokeMethod("onAdEvent", argumentsMap("adEventType", event.name, "error", event.message));
                    else -> methodChannel?.invokeMethod("onAdEvent", argumentsMap("adEventType", event.name));
                }
            }
            init(ad = ad, isTestAd = useTestAds)
        }
    }

    override fun getView(): View? {
        return adView
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "showAd" -> showAd(methodCall, result)
            "hideAd" -> hideAd(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun showAd(methodCall: MethodCall, result: MethodChannel.Result) {
        // val text = methodCall.arguments as String
        if (activity != null) {
            adView?.loadAd(activity!!)
            adView?.show()
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun hideAd(methodCall: MethodCall, result: MethodChannel.Result) {
        adView?.hide()
        result.success(true)
    }

    override fun dispose() {
        adView = null
        methodChannel = null
        platformThreadHandler = null
    }

    private fun argumentsMap(vararg args: Any): Map<String, Any>? {
        val arguments: MutableMap<String, Any> = HashMap()
        arguments["id"] = id
        var i = 0
        while (i < args.size) {
            arguments[args[i].toString()] = args[i + 1]
            i += 2
        }
        return arguments
    }
}

sealed class YieldAdEvent(val name: String) {
    class OnAdRequestBuild(): YieldAdEvent("onAdRequestBuild")
    class OnAdFailedToLoad(val message: String): YieldAdEvent("onAdFailedToLoad")
    class OnAdLoaded(): YieldAdEvent("onAdLoaded")
    class OnAdOpened(): YieldAdEvent("onAdOpened")
    class OnAdClicked(): YieldAdEvent("onAdClicked")
    class OnAdImpression(): YieldAdEvent("onAdImpression")
    class OnAdClosed(): YieldAdEvent("onAdClosed")
}