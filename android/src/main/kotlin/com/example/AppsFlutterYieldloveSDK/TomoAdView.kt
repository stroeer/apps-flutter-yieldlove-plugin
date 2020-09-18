package com.example.AppsFlutterYieldloveSDK

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.text.TextUtils
import android.util.AttributeSet
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
import com.example.AppsFlutterYieldloveSDK.R


// TODO params to extract: USE_TEST_AD_TAGS, isRelease, adModel

class TomoAdView : ConstraintLayout, AdClickListener2 {

    @LayoutRes
    private val layout: Int = R.layout.tomo_ad_view

    private var adView : ViewGroup? = null

    var USE_TEST_AD_TAGS = false // TODO arty

    var isVisible = false

    var contentUrl: String? = null

override    fun isRelease() = false // TODO arty


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

    constructor(context: Context, visible: Int = View.VISIBLE, backgroundColorRes: Int) : super(context) {
        visibility = visible
        setBackgroundColor(resources.getColor(backgroundColorRes))
        View.inflate(context, layout, this)
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        setBackgroundColor(resources.getColor(R.color.adTomoViewBackground))

        val attributes = context.obtainStyledAttributes(attrs, R.styleable.AdViewAttrs)
        val adLayout = attributes.getResourceId(R.styleable.AdViewAttrs_layout, layout)
       // visibility = View.GONE
        View.inflate(context, adLayout, this)
    }

    fun yieldloveAdView(ad: Ad? = null, isTestAd: Boolean = false) {
        if (ad != null) {
            adKeyword = ad.keyword
            if (isTestAd) prepareTestDfpAdView(this) else prepareDfpAdView(this, ad)
            //loadAd(null)
        }
    }

    private fun prepareDfpAdView(parentView: View, adModel: Ad, adWithLines: Boolean = false) {
        return prepareDfpAdView(parentView,
                adId = if (USE_TEST_AD_TAGS) testAdUnitId else adModel.adUnitId,
                adSizes = if (USE_TEST_AD_TAGS) testAdSizes else adModel.adSizes
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

        val height = AdParameter.dimensions["${adUnitId!!}-height"]
        if (height != null && height > 0) {
            val width = AdParameter.dimensions["${adUnitId!!}-width"]!!
            findViewById<View>(R.id.ad_placeholder)?.layoutParams = LayoutParams(width, height)
        }
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

            adUnit.addCustomTargeting("rse", LifecycleListener.sessionRandom.toString()) // random session
            adUnit.addCustomTargeting("rpi", LifecycleListener.screenRandom.toString()) // random pi
            val pageViewCounter = if (LifecycleListener.screenCounter > 99) "100+" else LifecycleListener.screenCounter.toString()
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

            if (!isRelease()) {
                val randomValuesForPrint = "random-session = ${LifecycleListener.sessionRandom}, random-pi = ${LifecycleListener.screenRandom}, pi-counter = $pageViewCounter"
                if (adKeyword != null && contentUrl != null) {
                    Log.v("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, contentUrl = $contentUrl, tagKeyword = $adKeyword, $randomValuesForPrint")
                } else if (contentUrl != null) {
                    if (!isRelease()) Log.v("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, contentUrl = $contentUrl, $randomValuesForPrint")
                } else if (contentUrl == null && adKeyword == null) {
                    if (!isRelease()) Log.e("tomo-app-ad", "Loading ad $adUnitId: configId = $configId, but contentUrl is null!")
                }
            }

            YieldloveBannerAd(adUnit, activityContext, object: YieldloveBannerAdListener {
                override fun onAdInit(banner: YieldloveBannerAdView?) {
                    adView?.addView(banner?.adView)
                }

                override fun onAdLeftApplication(banner: YieldloveBannerAdView?) {
                    // ;
                }

                override fun onAdRequestBuild(): PublisherAdRequest.Builder? {
                    val extras = Bundle().apply {
                        putString("npa", "1")
                    }
                    return PublisherAdRequest.Builder()
                            .addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                }

                override fun onAdFailedToLoad(banner: YieldloveBannerAdView?, errorCode: Int) {
                    hide()
                }

                override fun onAdLoaded(banner: YieldloveBannerAdView?) {
                    show()
                }

                override fun onAdOpened(banner: YieldloveBannerAdView?) {
                    // ;
                }

                override fun onAdClosed(banner: YieldloveBannerAdView?) {
                    // ;
                }
            })
        } catch (e: YieldloveException) {
            e.printStackTrace()
        }
    }

    fun show() {
        if (adView == null || adUnitId == null) return

        //findViewById<View>(R.id.ad_placeholder)?.visibility = View.GONE TODO arty

        visibility = View.VISIBLE
        isVisible = true
        addOnAdClickListener(this, adUnitId!!)

        adView?.post {
            if (height > 0) {
                AdParameter.dimensions["${adUnitId!!}-height"] = height
                AdParameter.dimensions["${adUnitId!!}-width"] = width
            }
        }
    }

    fun hide() {
        // visibility = View.GONE TODO arty
        // isVisible = true TODO arty
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

        if (!isRelease()) Log.v("tomo-app-ad", "af: '$af', adslot: 'topmobile$adSlot', as: 'topmobile$adSlot'")
    }
}

interface AdClickListener2 {

    fun isRelease() = false // TODO arty
    fun addOnAdClickListener(layout: View, adUnitId: String) {
        if (isRelease()) {
            return
        }

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
