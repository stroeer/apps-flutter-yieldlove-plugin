
import 'dart:async';

import 'package:flutter/services.dart';

class AppsFlutterYieldloveSDK {
  static const MethodChannel _channel =
      const MethodChannel('AppsFlutterYieldloveSDK');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
