package com.example.AppsFlutterYieldloveSDK

import android.R
import android.app.Activity
import android.util.Log
import android.view.View
import com.yieldlove.adIntegration.YieldloveConsent
import android.view.ViewGroup

import androidx.annotation.NonNull
import com.example.AppsFlutterYieldloveSDK.ad_view.NativeAdViewFactory
import com.sourcepoint.cmplibrary.model.ConsentAction
import com.sourcepoint.cmplibrary.model.exposed.SPConsents
import com.yieldlove.adIntegration.Yieldlove
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import com.yieldlove.adIntegration.YieldloveConsentListener

/** AppsFlutterYieldloveSDKPlugin */
class AppsFlutterYieldloveSDKPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  companion object {
    const val TAG = "yieldlove-app"
  }

  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "initialize" -> callInitialize(call, result)
      "loadInterstitialAd" -> callInterstitialLoad(call, result)
      "showConsent" -> showConsent(call, result)
      "showPrivacyManager" -> showPrivacyManager(call, result)
      else -> result.notImplemented()
    }
  }

  private fun showConsent(call: MethodCall, result: MethodChannel.Result) {
    if (activity != null) {
      val authId: String? = call.argument("authId")
      val consent = if (authId != null) {
        YieldloveConsent(activity, ConsentListener(activity?.findViewById(R.id.content), channel), authId)
      } else {
        YieldloveConsent(activity, ConsentListener(activity?.findViewById(R.id.content), channel))
      }
      consent.collect()
    }
  }

  private fun showPrivacyManager(call: MethodCall, result: MethodChannel.Result) {
    if (activity != null) {
      val consent = YieldloveConsent(activity, R.id.content)
      consent.showPrivacyManager()
    }
  }

  private fun callInitialize(call: MethodCall, result: MethodChannel.Result) {
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

  private fun callInterstitialLoad(call: MethodCall, result: MethodChannel.Result) {
    InterstitialHolder.delegateMethodCall(call, result, channel)
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.v(TAG, "onAttachedToEngine")

    val messenger: BinaryMessenger = binding.getBinaryMessenger()
    binding.getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory(
              "de.stroeer.plugins/yieldlove_ad_view",
              NativeAdViewFactory(messenger,  /*containerView=*/null)
            )
    
    channel = MethodChannel(binding.binaryMessenger, "AppsFlutterYieldloveSDK")
    channel.setMethodCallHandler(this)
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.v(TAG, "onDetachedFromEngine")
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.v(TAG, "onAttachedToActivity")
    activity = binding.activity
    binding.activity?.let {
      AdPlatformView.activity = it
      InterstitialHolder.activity = it
    }
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

    activity = null
    // The Activity your plugin was associated with has been
    // destroyed due to config changes. It will be right back
    // but your plugin must clean up any references to that
    // Activity and associated resources.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.v(TAG, "onReattachedToActivityForConfigChanges")
    binding.activity?.let {
      AdPlatformView.activity = it
      InterstitialHolder.activity = it
    }
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


open class ConsentListener(
  private val parent: ViewGroup?,
  private val channel: MethodChannel?
) : YieldloveConsentListener {

  override fun onAction(consentView: View, consentAction: ConsentAction): ConsentAction {
    return consentAction
  }

  override fun OnConsentUIReady(consentView: View) {
    consentView.layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT
    )
    consentView.bringToFront()
    consentView.requestLayout()
    parent?.addView(consentView)

    channel?.invokeMethod("onConsentUIReady", null)
  }

  override fun OnConsentUIFinished(consentView: View?) {
    parent?.removeView(consentView)
    channel?.invokeMethod("onConsentUIFinished", null)
  }

  override fun OnConsentReady(consent: SPConsents) {
    consent.gdpr?.consent?.let { gdprConsent ->
      val acceptedVendors = mutableListOf<String>()

      gdprConsent.grants.forEach {
        if (it.value.granted) {
          acceptedVendors.add(it.key)
        }
      }

      val map: HashMap<String, Any> = hashMapOf<String, Any>(
              "consentString" to gdprConsent.euconsent,
              "acceptedVendors" to acceptedVendors,
              "acceptedCategories" to gdprConsent.acceptedCategories,
      )
      channel?.invokeMethod("onConsentReady", map)
    }
  }

  override fun OnError(p0: Throwable?) {
    //channel?.invokeMethod("onError", p0?.message?:"")
  }
}
