export 'src/ad_view_provider.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class YieldloveWrapper {

  final MethodChannel _channel;
  static final YieldloveWrapper _instance = YieldloveWrapper.private(
    const MethodChannel('AppsFlutterYieldloveSDK'),
  );

  static YieldloveWrapper get instance => _instance;

  YieldloveWrapper.private(MethodChannel channel) : _channel = channel;

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

  Future<bool> showInterstitial(
      {@required String adUnitId,
        String trackingId,
        bool analyticsEnabled = false}) {
    assert(adUnitId != null && adUnitId.isNotEmpty);
    assert(analyticsEnabled != null);
    return _invokeBooleanMethod("loadInterstitialAd", <String, dynamic>{
      'ad_unit_id': adUnitId,
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


