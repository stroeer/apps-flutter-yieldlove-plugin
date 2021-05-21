export 'src/ad_view_provider.dart';
export 'src/consent_provider.dart';

import 'dart:async';
import 'package:AppsFlutterYieldloveSDK/src/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class YieldloveWrapper {

  final MethodChannel _channel;
  static final YieldloveWrapper _instance = YieldloveWrapper.private(
    const MethodChannel('AppsFlutterYieldloveSDK'),
  );

  static YieldloveWrapper get instance => _instance;

  YieldloveWrapper.private(MethodChannel channel) : _channel = channel;

  String appId;


  void Function() _onConsentUIReady;
  void Function() _onConsentUIFinished;
  void Function(String errorCode) _onError;

  Future<dynamic> _loadAdConfig() async {

    /// always the same for Ströer Group
    var sourcepointAccountId = 375;

    var propertyId = 10452;

    var propertyName = 'android.app.wetter.info';

    var privacyManagerId = '305923';

    var response = await http.get(_yieldloveConfigUrl());
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      final modules = jsonResponse['modules'];
      final configKey = Environment.isAndroid
          ? 'SOURCEPOINT'
          : 'iOSSOURCEPOINT';
      final sourcePointModule = modules[1][configKey];

      sourcepointAccountId = int.parse(sourcePointModule['sourcepointAccountId']);
      propertyId = int.parse(sourcePointModule['propertyId']);
      propertyName = sourcePointModule['propertyName'];
      privacyManagerId = sourcePointModule['privacyManagerId'];
    }


    return null;
  }

  Uri _yieldloveConfigUrl() => Uri.parse('https://cdn.stroeerdigitalgroup.de/sdk/live/$appId/config.json');

  void showConsentDialog({
    void Function() onConsentUIReady,
    void Function() onConsentUIFinished,
    void Function(String errorCode) onError
  }) async {
    this._onConsentUIReady = onConsentUIReady;
    this._onConsentUIFinished = onConsentUIFinished;
    this._onError = onError;

    await _loadAdConfig();
  }

  void showConsentPrivacyManager({
    void Function() onConsentUIReady,
    void Function() onConsentUIFinished,
    void Function(String errorCode) onError
  }) async {
    this._onConsentUIReady = onConsentUIReady;
    this._onConsentUIFinished = onConsentUIFinished;
    this._onError = onError;

    await _loadAdConfig();
  }

  Future<bool> initialize(
      {@required String appId,
        String trackingId,
        bool analyticsEnabled = false}) async {
    assert(appId.isNotEmpty);

    this.appId = appId;

    return await _invokeBooleanMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

  /// This is only required for iOS clients.
  /// If you call this on Android platform this method does nothing!
  Future<bool> clearAdCache() async {
    if (Environment.isIOS) {
      debugPrint('clearAdCache()');
      return await _invokeBooleanMethod("clearAdCache", <String, dynamic>{});
    }
    return true;
  }

  Future<bool> showInterstitial(
      {@required String adUnitId,
        String trackingId,
        bool analyticsEnabled = false}) {
    assert(adUnitId.isNotEmpty);
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


