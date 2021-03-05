package com.example.AppsFlutterYieldloveSDK.ad_view

import android.content.Context
import android.view.View
import com.example.AppsFlutterYieldloveSDK.AdPlatformView

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeAdViewFactory(val messenger: BinaryMessenger,
                          val containerView: View?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, args: Any?): PlatformView? {
        val params = args as Map<String, Any>?
        return AdPlatformView(context, messenger, id, params, containerView) //, params, containerView)
    }

}
