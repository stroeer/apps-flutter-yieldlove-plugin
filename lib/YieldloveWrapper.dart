import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class YieldloveWrapper {

  final MethodChannel _channel;
  static final YieldloveWrapper _instance = YieldloveWrapper.private(
    const MethodChannel('AppsFlutterYieldloveSDK'),
  );

  static YieldloveWrapper get instance => _instance;

  YieldloveWrapper.private(MethodChannel channel) : _channel = channel;

  static final String testAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';



  Future<bool> initialize(
      {@required String appId,
        String trackingId,
        bool analyticsEnabled = false}) {
    assert(appId != null && appId.isNotEmpty);
    assert(analyticsEnabled != null);
    return _invokeBooleanMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

}


Future<bool> _invokeBooleanMethod(String method, [dynamic arguments]) async {
  final bool result = await YieldloveWrapper.instance._channel.invokeMethod<bool>(
    method,
    arguments,
  );
  return result;
}


