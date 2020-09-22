import 'dart:io';

import 'package:AppsFlutterYieldloveSDK/src/yieldlove_android.dart';
import 'package:AppsFlutterYieldloveSDK/src/yieldlove_ios.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'base_yield_ad_view.dart';

class AdCreationParams {

  String adId;
  String adKeyword;
  String adContentUrl;
  List<AdSize> adSizes;
  bool adIsRelease = false;
  bool useTestAds = false;

  AdCreationParams({@required this.adId, @required this.adSizes, this.adKeyword, this.adContentUrl, this.useTestAds, this.adIsRelease});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_sizes': _adSizesToStringList(),
      'ad_is_release': adIsRelease,
      'use_test_ads': useTestAds,
    };
  }

  List<String> _adSizesToStringList() => adSizes.map((e) => '${e.width}x${e.height}').toList();
}

class AdSize {
  int width;
  int height;

  AdSize(this.width, this.height);
}

class YieldloveAdView extends StatefulWidget {

  final AdCreationParams adParamsParcel;
  final Function onPlatformViewCreated;

  YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    this.adParamsParcel,
    this.onPlatformViewCreated,
  })  : super(key: key);

  /// Which gestures should be consumed by our view.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();

  Future<bool> dispose() {
    //return _invokeBooleanMethod("disposeAd", <String, dynamic>{'id': id}); TODO
  }

}

class _YieldloveAdViewState extends State<YieldloveAdView> {

  @override
  Widget build(BuildContext context) {
    return getBaseYieldAdView().build(
      context: context,
      gestureRecognizers: widget.gestureRecognizers,
      creationParams: widget.adParamsParcel,
    );
  }

  BaseYieldAdView getBaseYieldAdView() {
    BaseYieldAdView _adView;
    if (_adView == null) {
      if (Platform.isAndroid) {
        _adView = AndroidYieldAdView(onPlatformViewCreatedCallback: (int id) {
          widget.onPlatformViewCreated(YieldloveAdController(id));
        });
      } else if (Platform.isIOS) {
        _adView = IosYieldAdView(onPlatformViewCreatedCallback: (int id) {
          widget.onPlatformViewCreated(YieldloveAdController(id));
        });
      } else {
        throw UnsupportedError("Trying to use the default view implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _adView;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(YieldloveAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

}

class YieldloveAdController {

  YieldloveAdController(int id) : _channel = new MethodChannel('de.stroeer.plugins/adview_$id') {
    _channel.setMethodCallHandler(_handleMethod);
  }

  final MethodChannel _channel;
  AdEventListener listener;

  Future<void> showAd() async {
    return _channel.invokeMethod('showAd');
  }

  Future<void> hideAd() async {
    return _channel.invokeMethod('hideAd');
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    assert(call.arguments is Map);
    final Map<dynamic, dynamic> argumentsMap = call.arguments;

    final int id = argumentsMap['id'];

    switch (call.method) {
      case 'onAdEvent':
        final adEventType = call.arguments["adEventType"];
        final errorMessage = call.arguments["error"];
        listener?.call(_methodToMobileAdEvent[adEventType]);
        break;
      case 'adSizeDetermined':
        final screenHeight = call.arguments["screenHeight"];
        final adHeight = call.arguments["adHeight"];
        print("app-widget: $id: screenHeight=($screenHeight) adHeight=$adHeight ");
        break;
      default:
        print("ignore this call from native");
    }
    return Future<dynamic>.value(null);
  }

  static const Map<String, YieldAdEvent> _methodToMobileAdEvent =
  <String, YieldAdEvent>{
    'onAdInit': YieldAdEvent.init,
    'onAdLoaded': YieldAdEvent.loaded,
    'onAdRequestBuild': YieldAdEvent.requestBuild,
    'onAdFailedToLoad': YieldAdEvent.failedToLoad,
    'onAdOpened': YieldAdEvent.opened,
    'onAdLeftApplication': YieldAdEvent.leftApplication,
    'onAdClosed': YieldAdEvent.closed,
  };
}

enum YieldAdEvent {
  init,
  loaded,
  requestBuild,
  failedToLoad,
  opened,
  leftApplication,
  closed,
}

typedef void AdEventListener(YieldAdEvent event);