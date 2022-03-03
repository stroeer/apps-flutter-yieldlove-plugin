export 'src/ad_view_provider.dart';
export 'src/consent_provider.dart';

import 'dart:async';
import 'package:AppsFlutterYieldloveSDK/src/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  void Function(String errorMessage) _onInterstitialError;
  void Function() _onInterstitialDidShow;

  //Future<SourcepointCmp> _loadAdConfig() async {
  //  /// always the same for Ströer Group
  //  var sourcepointAccountId = 375;
  //
  //  var propertyId = Environment.isAndroid ? 17391 : 17390;
  //
  //  var propertyName =  Environment.isAndroid ? 'android.app.new.wetter.info' : 'ios.app.new.wetter.info';
  //
  //  var privacyManagerId = Environment.isAndroid? '503921' : '503924';
  //
  //  var response = await http.get(_yieldloveConfigUrl());
  //  if (response.statusCode == 200) {
  //    final jsonResponse = convert.jsonDecode(response.body);
  //    final modules = jsonResponse['modules'];
  //    final configKey = Environment.isAndroid
  //        ? 'SOURCEPOINT'
  //        : 'iOSSOURCEPOINT';
  //    final sourcePointModule = modules[1][configKey];
  //
  //    sourcepointAccountId = int.parse(sourcePointModule['sourcepointAccountId']);
  //    propertyId = int.parse(sourcePointModule['propertyId']);
  //    propertyName = sourcePointModule['propertyName'];
  //    privacyManagerId = sourcePointModule['privacyManagerId'];
  //  }
  //  return null;
  //}

  //Uri _yieldloveConfigUrl() => Uri.parse('https://cdn.stroeerdigitalgroup.de/sdk/live/$appId/config.json');

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

    //_channel.setMethodCallHandler(_handleEvent);
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
          //legIntCategories: _castDynamicList(call.arguments['legIntCategories']),
          //specialFeatures: _castDynamicList(call.arguments['specialFeatures']),
        );
        this._onConsentReady(consent);
        break;
      case 'didShowInterstitial':
        this._onInterstitialDidShow();
        break;
      case 'showInterstitialError':
        final errorMessage = call.arguments['errorMessage'];
        this._onInterstitialError(errorMessage);
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

  /*Map<String, > _castDynamicMap(Map<dynamic, dynamic> map) {

  }*/
  
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

    //_channel.setMethodCallHandler(_handleEvent);

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
    _channel.setMethodCallHandler(_handleEvent);

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

  Future<bool> showInterstitial({
    void Function() onInterstitialDidShow,
    void Function(String errorMessage) onInterstitialError,
    @required String adUnitId,
    String trackingId,
    bool analyticsEnabled = false})
  {
    this._onInterstitialDidShow = onInterstitialDidShow;
    this._onInterstitialError = onInterstitialError;
    
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


class GDPRUserConsent {

  const GDPRUserConsent({
    this.consentString,
    this.acceptedVendors,
    this.acceptedCategories,
    //this.legIntCategories,
    //this.specialFeatures
  });

  final String consentString;

  final List<String> acceptedVendors;

  final List<String> acceptedCategories;

  //final List<String> legIntCategories;

  //final List<String> specialFeatures;
}


enum ActionType {
  SHOW_OPTIONS,
  REJECT_ALL,
  ACCEPT_ALL,
  MSG_CANCEL,
  SAVE_AND_EXIT,
  PM_DISMISS
}

ActionType actionTypeFromCode(int code) {
  if (code == null) return null;

  switch (code) {
    case 12: return ActionType.SHOW_OPTIONS;
    case 13: return ActionType.REJECT_ALL;
    case 11: return ActionType.ACCEPT_ALL;
    case 15: return ActionType.MSG_CANCEL;
    case 1: return ActionType.SAVE_AND_EXIT;
    case 2: return ActionType.PM_DISMISS;
  }

  throw UnsupportedError('Unknown actionCode $code');
}