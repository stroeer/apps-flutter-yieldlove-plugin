package com.example.AppsFlutterYieldloveSDK

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.text.TextUtils
import android.util.AttributeSet
import android.util.DisplayMetrics
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.constraintlayout.widget.ConstraintLayout
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.material.snackbar.Snackbar
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAd
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAdListener
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAdView
import com.yieldlove.adIntegration.AdUnit.YieldloveAdUnit
import com.yieldlove.adIntegration.Yieldlove
import com.yieldlove.adIntegration.exceptions.YieldloveException


class AdView : ConstraintLayout, AdLongClickListener {

    @LayoutRes
    private val layout: Int = R.layout.tomo_ad_view
    private var adView : ViewGroup? = null

    var contentUrl: String? = null
    var isVisible = false
    var isRelease = false

    //private val testAdUnitId = "/4444/m.app.dev.test/start_b1"

    private var adUnitId: String? = null

    private var adKeyword: String? = null

    private var customTargeting: Map<String, String>? = null

    private var isTestAd: Boolean = false

    var adEventListener: ((YieldAdEvent) -> Unit)? = null
    var adSizeCallback: ((Int?, Int?) -> Unit)? = null
    var screenHeight = 0 // required to determine screen pixel ratio

    constructor(context: Context, visible: Int = View.VISIBLE, backgroundColorRes: Int) : super(context) {
        visibility = visible
        setBackgroundColor(resources.getColor(backgroundColorRes))
        View.inflate(context, layout, this)
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        setBackgroundColor(resources.getColor(R.color.adTomoViewBackground))

        val attributes = context.obtainStyledAttributes(attrs, R.styleable.AdViewAttrs)
        val adLayout = attributes.getResourceId(R.styleable.AdViewAttrs_layout, layout)
        visibility = View.GONE
        View.inflate(context, adLayout, this)
    }

    fun init(ad: Ad? = null, isTestAd: Boolean = false) {
        this.isTestAd = isTestAd
        if (ad != null) {
            adKeyword = ad.keyword
            customTargeting = ad.customTargeting
            //if (isTestAd)
            //    prepareDfpAdView(this, testAdUnitId)
            //else
            prepareDfpAdView(this, ad.adUnitId)
        }
    }

    private fun prepareDfpAdView(parentView: View, adId: String) {
        adUnitId = adId
        adView = parentView.findViewById(R.id.yieldlove_ad) as ViewGroup?
    }

    fun loadAd(activityContext: Context?) {
        adView?.removeAllViews()
        determineScreenDimensions(context = activityContext)
        adView?.visibility = View.VISIBLE

        if (adUnitId == null) {
            Log.e("app-ad", "Cannot load an ad without its id.")
            return
        }

        try {
            val builder = PublisherAdRequest.Builder()

            if (adKeyword != null) {
                builder.addCustomTargeting("keywords", adKeyword)
            }

            if (customTargeting != null) {
                for (key in customTargeting!!.keys) {
                    val value = customTargeting!![key]
                    builder.addCustomTargeting(key, value)
                }
            }

            builder.addCustomTargeting("rse", SessionValuesProvider.sessionRandom.toString())
            builder.addCustomTargeting("rpi", SessionValuesProvider.screenRandom.toString()) // random pi
            val pageViewCounter = if (SessionValuesProvider.screenCounter > 99) "100+" else SessionValuesProvider.screenCounter.toString()
            builder.addCustomTargeting("pvc", pageViewCounter) // page view counter

            if (isTestAd) {
                builder.addCustomTargeting("demo", "mobileads")
            }

            if (contentUrl != null) {
                builder.setContentUrl(contentUrl)
            }
            Yieldlove.getInstance().publisherAdRequestBuilder = builder

            if (!isRelease) {
                val randomValuesForPrint = "random-session = ${SessionValuesProvider.sessionRandom}, random-pi = ${SessionValuesProvider.screenRandom}, pi-counter = $pageViewCounter"
                if (adKeyword != null && contentUrl != null) {
                    Log.v("app-ad", "Loading ad $adUnitId: contentUrl = $contentUrl, tagKeyword = $adKeyword, $randomValuesForPrint")
                } else if (contentUrl != null) {
                    if (!isRelease) Log.v("tomo-app-ad", "Loading ad $adUnitId: contentUrl = $contentUrl, $randomValuesForPrint")
                } else if (contentUrl == null && adKeyword == null) {
                    if (!isRelease) Log.e("tomo-app-ad", "Loading ad $adUnitId, but contentUrl is null!")
                }
            }

            // publisherCallString is something like start_b2
            val ad = YieldloveBannerAd(activityContext)
            ad.load(adUnitId, object: YieldloveBannerAdListener {
                override fun onAdInit(banner: YieldloveBannerAdView?) {
                    adView?.addView(banner?.adView)
                    adEventListener?.invoke(YieldAdEvent.OnAdInit())
                }

                override fun onAdLeftApplication(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldAdEvent.OnAdLeftApplication())
                }

                override fun onAdRequestBuild(): PublisherAdRequest.Builder? {
                    adEventListener?.invoke(YieldAdEvent.OnAdRequestBuild())
                    val extras = Bundle().apply {
                        putString("npa", "1")
                    }
                    return PublisherAdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                }

                override fun onAdFailedToLoad(banner: YieldloveBannerAdView?, error: YieldloveException?) {
                    adEventListener?.invoke(YieldAdEvent.OnAdFailedToLoad(
                            message = error?.localizedMessage ?: "Error message is missing"))
                    hide()
                }

                override fun onAdLoaded(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldAdEvent.OnAdLoaded())
                    show()
                }

                override fun onAdOpened(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldAdEvent.OnAdOpened())
                }

                override fun onAdClosed(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldAdEvent.OnAdClosed())
                }
            })
        } catch (e: YieldloveException) {
            e.printStackTrace()
        }
    }

    fun sendDimensionsToFlutter() {
        // we need this inner container bc outer container ALWAYS takes all available space ("match_parent")
        // regardless of what sizes you declare in XML. Therefore we cannot reliably determine size
        // for the ad view without this trick
        val yadHeight = findViewById<View>(R.id.yieldlove_ad_inner_container)?.getHeight()
        val yadMeasuredHeight = findViewById<View>(R.id.yieldlove_ad_inner_container)?.getMeasuredHeight()
        adSizeCallback?.invoke(screenHeight, yadMeasuredHeight)
    }

    fun show() {
        if (adView == null || adUnitId == null) return

        visibility = View.VISIBLE
        isVisible = true
        if (!isRelease) {
            addOnAdClickListener(this, adUnitId!!)
        }

        adView?.post {
            sendDimensionsToFlutter()

        }
    }

    //override fun onMeasure ( widthMeasureSpec: Int, heightMeasureSpec: Int) {
    //    val mode = View.MeasureSpec.getMode(heightMeasureSpec)
    //    val height = View.MeasureSpec.getSize(heightMeasureSpec)
    //    Log.d("app-widget", "tomo ad layout pass: mode=${mode}     height=${height}")
    //    super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    //}

    private fun determineScreenDimensions(context: Context?) {
        val displayMetrics = DisplayMetrics()
        (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
        screenHeight = displayMetrics.heightPixels
        // screenWidth = displayMetrics.widthPixels
    }

    fun hide() {
        visibility = View.GONE
        isVisible = false
    }
}

interface AdLongClickListener {

    fun addOnAdClickListener(layout: View, adUnitId: String) {
        layout.setOnLongClickListener {
            Snackbar.make(layout, adUnitId, Snackbar.LENGTH_LONG)
                    .setAction("adUnitId kopieren") {
                        val clipboard = layout.context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clip = ClipData.newPlainText("ID", adUnitId)
                        clipboard.setPrimaryClip(clip)
                    }
                    .show()
            true
        }
    }
}
