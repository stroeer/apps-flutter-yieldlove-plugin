import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AdCreationParams {

  String adId;
  String adKeyword;
  String adContentUrl;
  bool adIsRelease = false;
  bool useTestAds = false;

  List<AdSize> optimalAdSizes; // is calculated based on adId

  AdCreationParams({@required this.adId, this.adKeyword, this.adContentUrl, this.useTestAds, this.adIsRelease}) {
    optimalAdSizes = _mapAdTypeToAdSize[this.adId];
    print("app-widget: optimalAdSizes=${optimalAdSizes.first.height}");
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_sizes': _adSizesToStringList(optimalAdSizes),
      'ad_is_release': adIsRelease,
      'use_test_ads': useTestAds,
    };
  }

  static const Map<String, List<AdSize>> _mapAdTypeToAdSize =
  <String, List<AdSize>>{
    //'all': [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
    'rubrik_b1': [AdSize(300, 250)],
    'rubrik_b2': [AdSize(320, 150)],
    'rubrik_b3': [AdSize(320, 50)],
    'rubrik_b4': [AdSize(320, 75)],
    'rubrik_b5': [AdSize(37, 31)],
    'm.app.dev.test/start_b1': [AdSize(320, 75)]
  };

  List<String> _adSizesToStringList(List<AdSize> adSizes) {
    this.optimalAdSizes = adSizes; 
    return adSizes.map((e) => '${e.width}x${e.height}').toList(); 
  }

  double getOptimalHeight() => optimalAdSizes.first.height.toDouble();
}

class AdSize {
  final int width;
  final int height;
  const AdSize(this.width, this.height);
}

class YieldloveAdView extends StatefulWidget {

  final AdCreationParams adParamsParcel;
  final Function onPlatformViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    this.adParamsParcel,
    this.onPlatformViewCreated,
  })  : super(key: key);

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();

}

class _YieldloveAdViewState extends State<YieldloveAdView> {
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    Widget _adView;
    if (_adView == null) {
      if (Platform.isAndroid) {
        return GestureDetector(
          // intercept long press event.
          onLongPress: () {},
          excludeFromSemantics: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("  ANZEIGE  "),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: widget.adParamsParcel.getOptimalHeight(),
                child: AndroidView(
                  key: _key,
                  viewType: 'de.stroeer.plugins/yieldlove_ad_view',
                  onPlatformViewCreated: (int id) {
                    if (widget.onPlatformViewCreated != null) {
                      widget.onPlatformViewCreated(YieldloveAdController(id));
                    }
                  },
                  gestureRecognizers: widget.gestureRecognizers,
                  layoutDirection: TextDirection.rtl,
                  creationParams: widget.adParamsParcel.toMap(),
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),
            ],
          ),
        );
      } else if (Platform.isIOS) {
        return GestureDetector(
          // intercept long press event.
          onLongPress: () {},
          excludeFromSemantics: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("  ANZEIGE  "),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: widget.adParamsParcel.getOptimalHeight(),
                child: UiKitView(
                  key: _key,
                  viewType: 'de.stroeer.plugins/yieldlove_ad_view',
                  onPlatformViewCreated: (int id) {
                    if (widget.onPlatformViewCreated != null) {
                      widget.onPlatformViewCreated(YieldloveAdController(id));
                    }
                  },
                  gestureRecognizers: widget.gestureRecognizers,
                  layoutDirection: TextDirection.rtl,
                  creationParams: widget.adParamsParcel.toMap(),
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),
            ],
          ),
        );
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