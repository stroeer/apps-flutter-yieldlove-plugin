import 'dart:async';
import 'dart:io';

import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:AppsFlutterYieldloveSDK/src/ad_creation_params.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

export 'package:AppsFlutterYieldloveSDK/src/ad_creation_params.dart';

class YieldloveAdView extends StatefulWidget {

  const YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    @required this.adParamsParcel,
    this.onPlatformViewCreated,
    this.placedInsideScrollView = false,
  }) : super(key: key);

  final AdCreationParams adParamsParcel;
  final Function onPlatformViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final bool placedInsideScrollView;

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();

}

class _YieldloveAdViewState extends VisibilityAwareState<YieldloveAdView> {
  final UniqueKey _key = UniqueKey();

  @override
  void onVisibilityChanged(WidgetVisibility visibility) {
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        break;
      case WidgetVisibility.GONE:
        YieldloveWrapper.instance.clearAdCache();
        break;
      default:
        break;
    }
    super.onVisibilityChanged(visibility);
  }

  static Map<String, int> adControllerMap = {};

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
            SizedBox(
              width: widget.adParamsParcel?.getOptimalWidth(),
              height: widget.adParamsParcel?.getOptimalHeight(),
              child: false ? Container() : UiKitView(
                key: _key,
                viewType: 'de.stroeer.plugins/yieldlove_ad_view',
                onPlatformViewCreated: (int id) {
                  if (widget.onPlatformViewCreated != null) {
                    int theId = adControllerMap[widget.adParamsParcel?.adId];
                    if (theId == null) {
                      adControllerMap[widget.adParamsParcel?.adId] = id;
                      theId = id;
                    }
                    widget.onPlatformViewCreated(YieldloveAdController(theId));
                  }
                },
                gestureRecognizers: widget.gestureRecognizers,
                layoutDirection: TextDirection.ltr,
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
    'onAdLoaded': YieldAdEvent.loaded,
    'onAdRequestBuild': YieldAdEvent.requestBuild,
    'onAdFailedToLoad': YieldAdEvent.failedToLoad,
    'onAdOpened': YieldAdEvent.opened,
    'onAdClosed': YieldAdEvent.closed,
    'onAdClicked': YieldAdEvent.clicked,
    'onAdImpression': YieldAdEvent.impression,
  };
}

enum YieldAdEvent {
  loaded,
  requestBuild,
  failedToLoad,
  opened,
  closed,
  clicked,
  impression,
}

typedef void AdEventListener(YieldAdEvent event);