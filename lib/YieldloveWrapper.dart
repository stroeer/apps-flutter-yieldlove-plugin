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

  SourcepointCmp _sourcepointCmp;

  void Function() _onConsentUIReady;
  void Function() _onConsentUIFinished;
  void Function(ActionType) _onAction;
  void Function(GDPRUserConsent consent) _onConsentGiven;
  void Function(String errorCode) _onError;

  Future<SourcepointCmp> _loadAdConfig() async {
    if (_sourcepointCmp != null) {
      return _sourcepointCmp;
    }

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

    _sourcepointCmp = SourcepointCmp(
        accountId: sourcepointAccountId,
        propertyId: propertyId,
        propertyName: propertyName,
        pmId: privacyManagerId,
        onConsentUIReady: () {
          if (_onConsentUIReady != null) _onConsentUIReady();
        },
        onConsentUIFinished: () {
          if (_onConsentUIFinished != null) _onConsentUIFinished();
        },
        onAction: (ActionType actionType) {
          if (_onAction != null) _onAction(actionType);
        },
        onConsentReady: ({GDPRUserConsent consent}) {
          print('consentReady');
          if (_onConsentGiven != null) _onConsentGiven(consent);
        },
        onError: (String errorCode) {
          print('consentError: errorCode:$errorCode');
          if (_onError != null) _onError(errorCode);
        },
    );

    return _sourcepointCmp;
  }

  Uri _yieldloveConfigUrl() => Uri.parse('https://cdn.stroeerdigitalgroup.de/sdk/live/$appId/config.json');

  void showConsentDialog({
    void Function() onConsentUIReady,
    void Function() onConsentUIFinished,
    void Function(ActionType) onAction,
    void Function(GDPRUserConsent consent) onConsentGiven,
    void Function(String errorCode) onError
  }) async {
    this._onConsentUIReady = onConsentUIReady;
    this._onConsentUIFinished = onConsentUIFinished;
    this._onAction = onAction;
    this._onConsentGiven = onConsentGiven;
    this._onError = onError;

    await _loadAdConfig();
    _sourcepointCmp.load();
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
    this._onConsentGiven = onConsentGiven;
    this._onError = onError;

    await _loadAdConfig();
    _sourcepointCmp.showPM();
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


