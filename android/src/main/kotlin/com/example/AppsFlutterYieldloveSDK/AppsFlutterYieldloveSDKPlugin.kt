package com.example.AppsFlutterYieldloveSDK

import android.util.Log
import androidx.annotation.NonNull
import com.example.AppsFlutterYieldloveSDK.ad_view.NativeAdViewFactory
import com.example.AppsFlutterYieldloveSDK.consent.NativeConsentViewFactory
import com.yieldlove.adIntegration.Yieldlove
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

/** AppsFlutterYieldloveSDKPlugin */
class AppsFlutterYieldloveSDKPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "initialize" -> callInitialize(call, result)
      "loadInterstitialAd" -> callInterstitialLoad(call, result)
      else -> result.notImplemented()
    }
  }

  private fun callInitialize(call: MethodCall, result: Result) {
    val appId: String? = call.argument("appId")
    if (appId == null || appId.isEmpty()) {
      result.error("no_app_id", "a null or empty AdMob appId was provided", null)
      return
    } else {
      try {
        Yieldlove.setApplicationName(appId)
        result.success(true)
      } catch (e: Exception) {
        result.error("initialization_failed", "Yieldlove SDK initialization failed: ${e.message}", null)
      }
    }
  }

  private fun callInterstitialLoad(call: MethodCall, result: Result) {
    InterstitialHolder.delegateMethodCall(call, result)
  }

  companion object {
    const val TAG = "yieldlove-app"
  }


  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.v(TAG, "onAttachedToEngine")

    val messenger: BinaryMessenger = binding.getBinaryMessenger()
    binding.getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory("de.stroeer.plugins/yieldlove_ad_view",
                    NativeAdViewFactory(messenger,  /*containerView=*/null))

    binding.getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory("de.stroeer.plugins/consent_view",
                    NativeConsentViewFactory(messenger,  /*containerView=*/null))
    
    channel = MethodChannel(binding.binaryMessenger, "AppsFlutterYieldloveSDK")
    channel.setMethodCallHandler(this)
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.v(TAG, "onDetachedFromEngine")
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.v(TAG, "onAttachedToActivity")
    AdPlatformView.activity = binding.activity
    ConsentPlatformView.activity = binding.activity
    InterstitialHolder.activity = binding.activity
    //MobileAds.initialize(binding.activity)
    // Your plugin is now associated with an Android Activity.
    //
    // If this method is invoked, it is always invoked after
    // onAttachedToFlutterEngine().
    //
    // You can obtain an Activity reference with
    // binding.getActivity()
    //
    // You can listen for Lifecycle changes with
    // binding.getLifecycle()
    //
    // You can listen for Activity results, new Intents, user
    // leave hints, and state saving callbacks by using the
    // appropriate methods on the binding.


  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.v(TAG, "onDetachedFromActivityForConfigChanges")

    // The Activity your plugin was associated with has been
    // destroyed due to config changes. It will be right back
    // but your plugin must clean up any references to that
    // Activity and associated resources.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.v(TAG, "onReattachedToActivityForConfigChanges")
    // Your plugin is now associated with a new Activity instance
    // after config changes took place. You may now re-establish
    // a reference to the Activity and associated resources.
  }

  override fun onDetachedFromActivity() {
    Log.v(TAG, "onDetachedFromActivity")
    // Your plugin is no longer associated with an Activity.
    // You must clean up all resources and references. Your
    // plugin may, or may not ever be associated with an Activity
    // again.
  }
}
