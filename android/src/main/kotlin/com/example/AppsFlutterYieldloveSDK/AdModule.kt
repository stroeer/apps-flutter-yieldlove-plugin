package com.example.AppsFlutterYieldloveSDK

import com.google.android.gms.ads.AdSize

data class Size(val width: Int, val height: Int)

class Ad(val id: String, val possibleSizes: List<Size>, val keyword: String? = null) {
    val AD_UNIT_PREFIX = "/4444/m.app.droid_toi_sd"
    //val AD_UNIT_PREFIX = "m.app.ios_toi_t-o_wetter_sd"

    val adUnitId: String = "$AD_UNIT_PREFIX/$id"
    val adSizes : Array<AdSize> = possibleSizes.map { AdSize(it.width, it.height) }.toTypedArray()
}