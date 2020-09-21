package com.example.AppsFlutterYieldloveSDK

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

class YieldlovePlatformView internal constructor(val context: Context?,
                                                 val messenger: BinaryMessenger?,
                                                 id: Int,
                                                 params: Map<String, Any>?,
                                                 containerView: View?)
    : PlatformView, MethodCallHandler {

    companion object {
            var activity: Activity? = null
    }

    private var tomoAdView: TomoAdView? = null
    private lateinit var methodChannel: MethodChannel
    private var platformThreadHandler: Handler? = null

    init {
        var adId: String = "rubrik_b3"
        var adKeyword: String? = "ad_keyword"
        var adContentUrl: String? = "ad_content_url"
        var adSizes: List<Size> = emptyList()

        if (params?.containsKey("ad_id") == true) {
            adId = params["ad_id"] as String
            adKeyword = params["ad_keyword"] as String?
            adContentUrl = params["ad_content_url"] as String?
            adSizes = (params["ad_sizes"] as List<String>).map { e -> Size(e.split("x")[0].toInt(), e.split("x")[1].toInt()) }
            Log.e("app-platform-view", "Ad(id=${adId}, keyword=${adKeyword}, contentUrl=${adContentUrl}, adSizes=${adSizes} ")


        }

        //val addSizes = Arrays.asList(Size(320, 50), Size(320, 75), Size(320, 150), Size(300, 250), Size(37, 31))
        tomoAdView = createAdView(context, Ad(adId, adSizes, adKeyword), adContentUrl, null)

        platformThreadHandler = Handler(context!!.mainLooper)
        methodChannel = MethodChannel(messenger, "de.stroeer.plugins/adview_$id")
        methodChannel.setMethodCallHandler(this)
    }

    private fun createAdView(context1: Context?, ad: Ad, contentUrl: String?, layoutParams: ViewGroup.LayoutParams?): TomoAdView? {
        if (context1 == null) return null

        val height: Int? = AdParameter.dimensions[ad.adUnitId]
        if (height != null && height > 0) {
            // layoutParams.height = height TODO arty
        }
        val isVisible = if (height != null && height > 0) View.VISIBLE else View.GONE
        return TomoAdView(
                context = context1,
                visible = View.VISIBLE,
                backgroundColorRes = R.color.moduleBackground
        ).apply {
            yieldloveAdView(ad = ad)
            // TODO arty layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            this.contentUrl = contentUrl
            //visibility = View.GONE TODO arty
            //loadAd(context1)
        }
    }


    override fun getView(): View? {
        return tomoAdView
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "setText" -> setText(methodCall, result)
            "showAd" -> showAd(methodCall, result)
            "hideAd" -> hideAd(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun showAd(methodCall: MethodCall, result: MethodChannel.Result) {
        tomoAdView?.loadAd(activity)
        tomoAdView?.show()
    }

    private fun hideAd(methodCall: MethodCall, result: MethodChannel.Result) {
        tomoAdView?.hide()
    }


    private fun setText(methodCall: MethodCall, result: MethodChannel.Result) {
        val text = methodCall.arguments as String
        //textView.setText(text)
        result.success(null)
    }

    override fun dispose() {
    }
}