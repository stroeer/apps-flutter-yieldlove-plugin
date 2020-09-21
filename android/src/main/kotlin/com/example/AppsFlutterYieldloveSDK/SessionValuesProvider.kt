package com.example.AppsFlutterYieldloveSDK

import kotlin.random.Random

object SessionValuesProvider {
    var sessionRandom: Int = Random.nextInt(1, 21)
    var screenCounter: Int = 0
        set(value) {
            field = value
            screenRandom = Random.nextInt(1, 21)
        }
    var screenRandom: Int = 1
}