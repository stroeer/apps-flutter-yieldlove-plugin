export 'src/ad_view_provider.dart';
export 'src/consent_provider.dart';

import 'dart:async';
import 'package:AppsFlutterYieldloveSDK/src/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

export 'package:sourcepoint_cmp/action_type.dart';
export 'package:sourcepoint_cmp/gdpr_user_consent.dart';

class YieldloveWrapper {

  final MethodChannel _channel;
  static final YieldloveWrapper _instance = YieldloveWrapper.private(
    const MethodChannel('AppsFlutterYieldloveSDK'),
  );

  static YieldloveWrapper get instance => _instance;

  YieldloveWrapper.private(MethodChannel channel) : _channel = channel;

  String appId;

  //SourcepointCmp _sourcepointCmp;

  void Function() _onConsentUIReady;
  void Function() _onConsentUIFinished;
  void Function(ActionType) _onAction;
  void Function(GDPRUserConsent consent) _onConsentReady;
  void Function(String errorCode) _onError;

  Future<SourcepointCmp> _loadAdConfig() async {
    /// always the same for Ströer Group
    var sourcepointAccountId = 375;

    var propertyId = Environment.isAndroid ? 17391 : 17390;

    var propertyName =  Environment.isAndroid ? 'android.app.new.wetter.info' : 'ios.app.new.wetter.info';

    var privacyManagerId = Environment.isAndroid? '503921' : '503924';

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
    void Function(ActionType) onAction,
    void Function(GDPRUserConsent consent) onConsentGiven,
    void Function(String errorCode) onError,
    String authId,
  }) async {
    this._onConsentUIReady = onConsentUIReady;
    this._onConsentUIFinished = onConsentUIFinished;
    this._onAction = onAction;
    this._onConsentReady = onConsentGiven;
    this._onError = onError;

    await _loadAdConfig();

    _channel.setMethodCallHandler(_handleEvent);
    await _channel.invokeMethod('showConsent', <String, dynamic>{
      'authId': authId,
      //'accountId': accountId,
      //'propertyId': propertyId,
      //'propertyName': propertyName,
      //'pmId': pmId
    });
  }


  /// Handles returned events
  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
      case 'onConsentUIReady':
        this._onConsentUIReady();
        break;
      case 'onConsentUIFinished':
        this._onConsentUIFinished();
        break;
      case 'onConsentReady':
        GDPRUserConsent consent = GDPRUserConsent(
          consentString: call.arguments['consentString'],
          acceptedVendors: _castDynamicList(call.arguments['acceptedVendors']),
          acceptedCategories: _castDynamicList(call.arguments['acceptedCategories']),
          legIntCategories: _castDynamicList(call.arguments['legIntCategories']),
          specialFeatures: _castDynamicList(call.arguments['specialFeatures']),
        );
        this._onConsentReady(consent);
        break;
      case 'didShowInterstitial':
        debugPrint("Showing Interstitial");
        break;
      case 'showInterstitialError':
        final errorMessage = call.arguments['errorMessage'];
        debugPrint("Error showing interstitial: ${errorMessage}");
        break;
      case 'onError':
        var debugDescription = call.arguments as String;
        this._onError(debugDescription);
        break;
    }
    return null;
  }

  List<String> _castDynamicList(List<dynamic> list) {
    if (list == null) return [];

    return List<String>.from(list.map((value) => value as String));
  }
  
  void showConsentPrivacyManager({
    void Function() onConsentUIReady,
    void Function() onConsentUIFinished,
    void Function(ActionType) onAction,
    void Function(GDPRUserConsent consent) onConsentGiven,
    void Function(String errorCode) onError
  }) async {
    this._onConsentUIReady = onConsentUIReady;
    this._onConsentUIFinished = onConsentUIFinished;
    this._onAction = onAction;
    this._onConsentReady = onConsentGiven;
    this._onError = onError;

    await _loadAdConfig();
    _channel.setMethodCallHandler(_handleEvent);

    await _channel.invokeMethod('showPrivacyManager', <String, dynamic>{
      //'accountId': accountId,
      //'propertyId': propertyId,
      //'propertyName': propertyName,
      //'pmId': pmId
    });
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
    _channel.setMethodCallHandler(_handleEvent);
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


