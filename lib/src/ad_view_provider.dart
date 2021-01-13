import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AdCreationParams {

  final String adId;
  final String? adKeyword;
  final String? adContentUrl;
  final bool? adIsRelease;
  final bool? useTestAds;

  /// List of AdSize is optional
  /// fallback AdSize is AdSize(width: 300, height: 250)
  ///
  /// Note: Right now only one ad size is supported by this plugin, the second
  /// AdSize will be ignored!
  final List<AdSize>? adSizes;

  List<AdSize> optimalAdSizes = []; // is calculated based on adId

  AdCreationParams({
    required this.adId,
    this.adKeyword,
    this.adContentUrl,
    this.adSizes,
    this.useTestAds = false,
    this.adIsRelease = false
  }) {
    if (adSizes != null) {
      assert(adSizes!.isNotEmpty, 'The adSizes list should never be empty!');
    }
    optimalAdSizes = _mapAdTypeToAdSize[this.adId] ?? [AdSize(width: 300, height: 150)];
    print("app-widget: optimalAdSizes=${optimalAdSizes.first.height}");
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_sizes': adSizes ?? _adSizesToStringList(optimalAdSizes),
      'ad_is_release': adIsRelease,
      'use_test_ads': useTestAds,
    };
  }

  static const Map<String, List<AdSize>> _mapAdTypeToAdSize =
  <String, List<AdSize>>{
    //'all': [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
    'rubrik_b1': [AdSize(width: 300, height: 250)],
    'rubrik_b2': [AdSize(width: 320, height: 150)],
    'rubrik_b3': [AdSize(width: 320, height: 50)],
    'rubrik_b4': [AdSize(width: 320, height: 75)],
    'rubrik_b5': [AdSize(width: 37, height: 31)],
    'm.app.dev.test/start_b1': [AdSize(width: 320, height: 75)]
  };

  List<String> _adSizesToStringList(List<AdSize> adSizes) {
    this.optimalAdSizes = adSizes; 
    return adSizes.map((e) => '${e.width}x${e.height}').toList(); 
  }

  double getOptimalHeight() => (adSizes ?? optimalAdSizes).first.height.toDouble();
}

class AdSize {
  final int width;
  final int height;
  const AdSize({
    required this.width,
    required this.height
  });
}

class YieldloveAdView extends StatefulWidget {

  const YieldloveAdView({
    Key? key,
    this.gestureRecognizers,
    required this.adParamsParcel,
    this.onPlatformViewCreated,
  }) : super(key: key);

  final AdCreationParams? adParamsParcel;
  final Function? onPlatformViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();

}

class _YieldloveAdViewState extends State<YieldloveAdView> {
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return GestureDetector(
        // intercept long press event.
        onLongPress: () {},
        excludeFromSemantics: true,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: widget.adParamsParcel?.getOptimalHeight(),
              child: AndroidView(
                key: _key,
                viewType: 'de.stroeer.plugins/yieldlove_ad_view',
                onPlatformViewCreated: (int id) {
                  if (widget.onPlatformViewCreated != null) {
                    widget.onPlatformViewCreated!(YieldloveAdController(id));
                  }
                },
                gestureRecognizers: widget.gestureRecognizers,
                layoutDirection: TextDirection.rtl,
                creationParams: widget.adParamsParcel?.toMap(),
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
            SizedBox(
              width: double.infinity,
              height: widget.adParamsParcel?.getOptimalHeight(),
              child: UiKitView(
                key: _key,
                viewType: 'de.stroeer.plugins/yieldlove_ad_view',
                onPlatformViewCreated: (int id) {
                  if (widget.onPlatformViewCreated != null) {
                    widget.onPlatformViewCreated!(YieldloveAdController(id));
                  }
                },
                gestureRecognizers: widget.gestureRecognizers,
                layoutDirection: TextDirection.rtl,
                creationParams: widget.adParamsParcel?.toMap(),
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
  AdEventListener? listener;

  Future<void> showAd() async {
    return _channel.invokeMethod('showAd');
  }

  Future<void> hideAd() async {
    return _channel.invokeMethod('hideAd');
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    assert(call.arguments is Map);
    final Map<dynamic, dynamic> argumentsMap = call.arguments;

    final int? id = argumentsMap['id'];

    switch (call.method) {
      case 'onAdEvent':
        final adEventType = call.arguments["adEventType"];
        final errorMessage = call.arguments["error"];
        final event = _methodToMobileAdEvent[adEventType];
        if (event != null) {
          listener?.call(event);
        }
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