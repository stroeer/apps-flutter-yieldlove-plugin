package com.example.AppsFlutterYieldloveSDK.consent

import android.content.Context
import android.view.View
import com.example.AppsFlutterYieldloveSDK.ConsentPlatformView

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeConsentViewFactory(val messenger: BinaryMessenger,
                               val containerView: View?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, args: Any?): PlatformView? {
        val params = args as Map<String, Any>?
        return ConsentPlatformView(context, messenger, id, params, containerView) //, params, containerView)
    }

}
