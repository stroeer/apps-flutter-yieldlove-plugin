package com.example.AppsFlutterYieldloveSDK

class Ad(val id: String, val keyword: String? = null) {
    // TODO: Which prefix is correct?
    val AD_UNIT_PREFIX = "/4444/m.app.droid_toi_sd"
    //val AD_UNIT_PREFIX = "m.app.ios_toi_t-o_wetter_sd"

    val adUnitId: String = "$AD_UNIT_PREFIX/$id"
}