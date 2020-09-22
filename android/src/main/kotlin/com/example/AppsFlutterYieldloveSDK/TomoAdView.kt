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


class TomoAdView : ConstraintLayout, AdLongClickListener {

    @LayoutRes
    private val layout: Int = R.layout.tomo_ad_view
    private var adView : ViewGroup? = null

    var contentUrl: String? = null
    var isVisible = false
    var isRelease = false
    var useTestAds = false

    private val testAdUnitId = "/4444/m.app.dev.test/start_b1"

    private val testAdSizes: Array<AdSize> = arrayOf(
            AdSize.BANNER,
            AdSize.LARGE_BANNER,
            AdSize.FULL_BANNER,
            AdSize.MEDIUM_RECTANGLE,
            AdSize.SMART_BANNER,
            AdSize.WIDE_SKYSCRAPER,
            AdSize.LEADERBOARD,
            AdSize.FLUID
    )

    private var adSizes: Array<AdSize> = testAdSizes

    private var adUnitId: String? = null

    private var adKeyword: String? = null

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
        if (ad != null) {
            adKeyword = ad.keyword
            if (isTestAd) prepareTestDfpAdView(this) else prepareDfpAdView(this, ad)
        }
    }

    private fun prepareDfpAdView(parentView: View, adModel: Ad, adWithLines: Boolean = false) {
        return prepareDfpAdView(parentView,
                adId = if (useTestAds) testAdUnitId else adModel.adUnitId,
                adSizes = if (useTestAds) testAdSizes else adModel.adSizes
        )
    }

    private fun prepareTestDfpAdView(parentView: View) {
        return prepareDfpAdView(parentView, testAdUnitId, testAdSizes)
    }

    private fun prepareDfpAdView(parentView: View, adId: String, adSizes: Array<AdSize>) {
        adUnitId = adId
        adView = parentView.findViewById(R.id.yieldlove_ad) as ViewGroup?
        this.adSizes = adSizes
    }

    fun loadAd(activityContext: Context?) {
        adView?.removeAllViews()
        determineScreenDimensions(context = activityContext)
        findViewById<View>(R.id.ad_placeholder)?.visibility = View.VISIBLE
        adView?.visibility = View.VISIBLE

        if (adUnitId == null) {
            Log.e("tomo-app-ad", "Cannot load an ad without its id.")
            return
        }

        try {
            val configId: String = if (adUnitId!!.contains("rubrik_b1")) {
                "23904"
            } else if (adUnitId!!.contains("rubrik_b2")) {
                "23928"
            } else if (adUnitId!!.contains("rubrik_b3")) {
                "23931"
            } else if (adUnitId!!.contains("rubrik_b4")) {
                "23933"
            } else if (adUnitId!!.contains("rubrik_b5")) {
                "23934"
            } else {
                Log.e("tomo-app-ad", "Failed to resolve the config id for ad $adUnitId.")
                return
            }
            val adUnit = YieldloveAdUnit(adUnitId, configId, adSizes)

            adUnit.addCustomTargeting("rse", SessionValuesProvider.sessionRandom.toString()) // random session
            adUnit.addCustomTargeting("rpi", SessionValuesProvider.screenRandom.toString()) // random pi
            val pageViewCounter = if (SessionValuesProvider.screenCounter > 99) "100+" else SessionValuesProvider.screenCounter.toString()
            adUnit.addCustomTargeting("pvc", pageViewCounter) // page view counter

            insertRecommendedTargeting(adUnit)

            if (adKeyword != null) {
                adUnit.addCustomTargeting("keywords", adKeyword)
            }

            val builder = PublisherAdRequest.Builder()
            if (contentUrl != null) {
                builder.setContentUrl(contentUrl)
            }
            Yieldlove.getInstance().publisherAdRequestBuilder = builder

            if (!isRelease) {
                val randomValuesForPrint = "random-session = ${SessionValuesProvider.sessionRandom}, random-pi = ${SessionValuesProvider.screenRandom}, pi-counter = $pageViewCounter"
                if (adKeyword != null && contentUrl != null) {
                    Log.v("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, contentUrl = $contentUrl, tagKeyword = $adKeyword, $randomValuesForPrint")
                } else if (contentUrl != null) {
                    if (!isRelease) Log.v("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, contentUrl = $contentUrl, $randomValuesForPrint")
                } else if (contentUrl == null && adKeyword == null) {
                    if (!isRelease) Log.e("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, but contentUrl is null!")
                }
            }

            YieldloveBannerAd(adUnit, activityContext, object: YieldloveBannerAdListener {
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

                override fun onAdFailedToLoad(banner: YieldloveBannerAdView?, errorCode: Int) {
                    adEventListener?.invoke(YieldAdEvent.OnAdFailedToLoad(message = errorCode.toString()))
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

        findViewById<View>(R.id.ad_placeholder)?.visibility = View.GONE

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

    private fun insertRecommendedTargeting(adUnit: YieldloveAdUnit) {
        // the "recommended" key value targeting
        // link: https://stroeerdigitalgroup.atlassian.net/wiki/spaces/SDGPUBLIC/pages/1263730994/Integration+in+Apps

        // (1) The af value (available format)
        val list: MutableList<String> = mutableListOf()
        // (300, 250) -> mrec
        if (adSizes.contains(AdSize(300, 250))) {
            list.add("mrec")
        }
        // (320, 50) -> mpres6x1 or moad6x1
        if (adSizes.contains(AdSize(320, 50))) {
            list.add("mpres6x1")
            list.add("moad6x1")
        }
        // (320, 75) -> moad4x1 or mpres4x1
        if (adSizes.contains(AdSize(320, 75))) {
            list.add("moad4x1")
            list.add("mpres4x1")
        }
        // (320, 100) -> moad3x1 or mpres3x1
        if (adSizes.contains(AdSize(320, 100))) {
            list.add("moad3x1")
            list.add("mpres3x1")
        }
        // (320, 150) -> moad2x1 or mpres2x1
        if (adSizes.contains(AdSize(320, 150))) {
            list.add("mpres2x1")
            list.add("moad2x1")
        }
        val af = TextUtils.join(",", list)
        adUnit.addCustomTargeting("af", af)

        // (2) adslot and and as
        val adSlot = if (adUnitId!!.contains("_b1")) {
            ""
        } else if (adUnitId!!.contains("_b2")) {
            "2"
        } else if (adUnitId!!.contains("_b3")) {
            "3"
        } else if (adUnitId!!.contains("_b4")) {
            "4"
        } else {
            ""
        }
        adUnit.addCustomTargeting("adslot", "topmobile$adSlot")
        adUnit.addCustomTargeting("as", "topmobile$adSlot")

        if (!isRelease) Log.v("tomo-app-ad", "af: '$af', adslot: 'topmobile$adSlot', as: 'topmobile$adSlot'")
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
