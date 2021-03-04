export 'src/ad_view_provider.dart';
export 'src/consent_provider.dart';

import 'dart:async';
import 'package:AppsFlutterYieldloveSDK/src/consent_listener.dart';
import 'package:AppsFlutterYieldloveSDK/src/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

export 'package:AppsFlutterYieldloveSDK/src/consent_listener.dart';
export 'package:sourcepoint_cmp/action_type.dart';
export 'package:sourcepoint_cmp/gdpr_user_consent.dart';

class YieldloveWrapper {

  final MethodChannel _channel;
  static final YieldloveWrapper _instance = YieldloveWrapper.private(
    const MethodChannel('AppsFlutterYieldloveSDK'),
  );

  static YieldloveWrapper get instance => _instance;

  YieldloveWrapper.private(MethodChannel channel) : _channel = channel;

  String? appId;

  SourcepointCmp? _sourcepointCmp;

  ConsentListener? _listener;

  Future<SourcepointCmp?> _loadAdConfig() async {
    if (_sourcepointCmp != null) {
      return _sourcepointCmp;
    }

    /// always the same for Ströer Group
    var sourcepointAccountId = 375;

    var propertyId = 10452;

    String? propertyName = 'android.app.wetter.info';

    String? privacyManagerId = '179267';

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
        propertyName: propertyName!,
        pmId: privacyManagerId!,
        onConsentUIReady: () {
          _listener?.onConsentUIReady();
        },
        onConsentUIFinished: () {
          _listener?.onConsentUIFinished();
        },
        onAction: (ActionType actionType) {
          _listener?.onAction(actionType);
        },
        onConsentReady: (GDPRUserConsent consent) {
          print('consentReady');
          _listener?.onConsentGiven(consent);
        },
        onError: (String? errorCode) {
          print('consentError: errorCode:$errorCode');
          _listener?.onError(errorCode);
        },

    );

    return _sourcepointCmp;
  }

  Uri _yieldloveConfigUrl() => Uri.parse('https://cdn.stroeerdigitalgroup.de/sdk/live/$appId/config.json');

  void showConsentDialog({ConsentListener? listener}) async {
    this._listener = listener;

    await _loadAdConfig();
    _sourcepointCmp!.load();
  }

  void showConsentPrivacyManager({ConsentListener? listener}) async {
    this._listener = listener;

    await _loadAdConfig();
    _sourcepointCmp!.showPM();
  }

  Future<bool?> initialize(
      {required String appId,
        String? trackingId,
        bool analyticsEnabled = false}) async {
    assert(appId.isNotEmpty);

    this.appId = appId;

    return _invokeBooleanMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

  Future<bool?> showInterstitial(
      {required String adUnitId,
        String? trackingId,
        bool analyticsEnabled = false}) {
    assert(adUnitId.isNotEmpty);
    return _invokeBooleanMethod("loadInterstitialAd", <String, dynamic>{
      'ad_unit_id': adUnitId,
    });
  }

}


Future<bool?> _invokeBooleanMethod(String method, [dynamic arguments]) async {
  final bool? result = await YieldloveWrapper.instance._channel.invokeMethod<bool>(
    method,
    arguments,
  );
  return result;
}


