package com.example.AppsFlutterYieldloveSDK

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.util.AttributeSet
import android.util.DisplayMetrics
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.constraintlayout.widget.ConstraintLayout
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAd
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAdListener
import com.yieldlove.adIntegration.AdFormats.YieldloveBannerAdView
import com.yieldlove.adIntegration.Yieldlove
import com.yieldlove.adIntegration.exceptions.YieldloveException


class ConsentView : ConstraintLayout {

    @LayoutRes
    private val layout: Int = R.layout.tomo_ad_view
    private var adView : ViewGroup? = null

    var contentUrl: String? = null
    var isVisible = false
    var isRelease = false

    private var adUnitId: String? = null

    private var adKeyword: String? = null

    private var customTargeting: Map<String, String>? = null

    private var isTestAd: Boolean = false

    var adEventListener: ((YieldConsentEvent) -> Unit)? = null
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
            Yieldlove.getInstance().publisherAdRequestBuilder = builder

            // publisherCallString is something like start_b2
            val ad = YieldloveBannerAd(activityContext)
            ad.load(adUnitId, object: YieldloveBannerAdListener {
                override fun onAdInit(banner: YieldloveBannerAdView?) {
                    adView?.addView(banner?.adView)
                    adEventListener?.invoke(YieldConsentEvent.OnAdInit())
                }

                override fun onAdLeftApplication(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldConsentEvent.OnAdLeftApplication())
                }

                override fun onAdRequestBuild(): PublisherAdRequest.Builder? {
                    adEventListener?.invoke(YieldConsentEvent.OnAdRequestBuild())
                    val extras = Bundle().apply {
                        putString("npa", "1")
                    }
                    return PublisherAdRequest.Builder().addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                }

                override fun onAdFailedToLoad(banner: YieldloveBannerAdView?, error: YieldloveException?) {
                    adEventListener?.invoke(YieldConsentEvent.OnAdFailedToLoad(
                            message = error?.localizedMessage ?: "Error message is missing"))
                    hide()
                }

                override fun onAdLoaded(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldConsentEvent.OnAdLoaded())
                    show()
                }

                override fun onAdOpened(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldConsentEvent.OnAdOpened())
                }

                override fun onAdClosed(banner: YieldloveBannerAdView?) {
                    adEventListener?.invoke(YieldConsentEvent.OnAdClosed())
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
