package com.example.AppsFlutterYieldloveSDK

data class Ad(
        val adUnitId: String,
        val keyword: String? = null,
        val customTargeting: Map<String, String>? = null
)