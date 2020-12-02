package com.example.AppsFlutterYieldloveSDK

import android.R.id
import android.app.Activity
import android.content.Context
import android.os.Handler
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.yieldlove.adIntegration.Yieldlove
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView
import java.util.*


class YieldlovePlatformView internal constructor(context: Context?,
                                                 messenger: BinaryMessenger?,
                                                 val id: Int,
                                                 params: Map<String, Any>?,
                                                 containerView: View?)
    : PlatformView, MethodCallHandler {

    companion object {
            var activity: Activity? = null
    }

    private var tomoAdView: TomoAdView? = null
    private var methodChannel: MethodChannel
    private var platformThreadHandler: Handler? = null

    init {
        var adId: String = "rubrik_b3"
        var adKeyword: String? = null
        var adContentUrl: String? = null
        var adSizes: List<Size> = emptyList()
        var adIsRelease: Boolean = false
        var useTestAds: Boolean = false

        if (params?.containsKey("ad_id") == true) {
            adId = params["ad_id"] as String
            adKeyword = params["ad_keyword"] as String?
            adContentUrl = params["ad_content_url"] as String?
            adIsRelease = params["ad_is_release"] as Boolean
            useTestAds = params["use_test_ads"] as Boolean
            adSizes = (params["ad_sizes"] as List<String>).map { e -> Size(e.split("x")[0].toInt(), e.split("x")[1].toInt()) }
            Log.v("app-platform-view", "Ad(id=${adId}, keyword=${adKeyword}, contentUrl=${adContentUrl}, adSizes=${adSizes}, adIsRelease=${adIsRelease}, adIsTest=${useTestAds}")
        }

        tomoAdView = createAdView(context, Ad(adId, adSizes, adKeyword), adContentUrl, null, adIsRelease, useTestAds)

        platformThreadHandler = Handler(context!!.mainLooper)
        methodChannel = MethodChannel(messenger, "de.stroeer.plugins/adview_$id")
        methodChannel.setMethodCallHandler(this)
    }

    private fun createAdView(context1: Context?,
                             ad: Ad,
                             contentUrl: String?,
                             layoutParams: ViewGroup.LayoutParams?,
                             isRelease: Boolean = false,
                             useTestAds: Boolean = false
    ): TomoAdView? {
        if (context1 == null) return null
        return TomoAdView(
                context = context1,
                visible = View.VISIBLE,
                backgroundColorRes = R.color.moduleBackground
        ).apply {
            this.contentUrl = contentUrl
            this.isRelease = isRelease
            this.visibility = View.GONE
            this.adSizeCallback = { screenHeight, adHeight ->
                methodChannel.invokeMethod("adSizeDetermined", argumentsMap("screenHeight", screenHeight ?: 0, "adHeight", adHeight ?: 0))
            }
            this.adEventListener = { event ->
                when (event) {
                    is YieldAdEvent.OnAdFailedToLoad -> methodChannel.invokeMethod("onAdEvent", argumentsMap("adEventType", event.name, "error", event.message));
                    else -> methodChannel.invokeMethod("onAdEvent", argumentsMap("adEventType", event.name));
                }
            }
            init(ad = ad, isTestAd = useTestAds)
        }
    }

    override fun getView(): View? {
        return tomoAdView
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
        tomoAdView?.loadAd(activity)
        tomoAdView?.show()
        result.success(true)
    }

    private fun hideAd(methodCall: MethodCall, result: MethodChannel.Result) {
        tomoAdView?.hide()
        result.success(true)
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
    class OnAdInit(): YieldAdEvent("onAdInit")
    class OnAdLeftApplication(): YieldAdEvent("onAdLeftApplication")
    class OnAdRequestBuild(): YieldAdEvent("onAdRequestBuild")
    class OnAdFailedToLoad(val message: String): YieldAdEvent("onAdFailedToLoad")
    class OnAdLoaded(): YieldAdEvent("onAdLoaded")
    class OnAdOpened(): YieldAdEvent("onAdOpened")
    class OnAdClosed(): YieldAdEvent("onAdClosed")
}