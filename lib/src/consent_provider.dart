import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'package:AppsFlutterYieldloveSDK/src/consent_provider.dart';

import 'package:AppsFlutterYieldloveSDK/src/ad_creation_params.dart';

class YieldloveConsentView extends StatefulWidget {

  const YieldloveConsentView({
    Key? key,
    this.gestureRecognizers,
    required this.adParamsParcel,
    this.onPlatformViewCreated,
  }) : super(key: key);

  final AdCreationParams adParamsParcel;
  final Function? onPlatformViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _YieldloveConsentViewState();

}

class _YieldloveConsentViewState extends State<YieldloveConsentView> {
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final double height = widget.adParamsParcel?.getOptimalHeight();
    if (Platform.isAndroid) {
      return GestureDetector(
        // intercept long press event.
        onLongPress: () {},
        excludeFromSemantics: true,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: height,
              child: AndroidView(
                key: _key,
                viewType: 'de.stroeer.plugins/consent_view',
                onPlatformViewCreated: (int id) {
                  if (widget.onPlatformViewCreated != null) {
                    widget.onPlatformViewCreated!(YieldloveConsentController(id));
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
              width: double.infinity,
              height: height,
              child: UiKitView(
                key: _key,
                viewType: 'de.stroeer.plugins/consent_view',
                onPlatformViewCreated: (int id) {
                  if (widget.onPlatformViewCreated != null) {
                    widget.onPlatformViewCreated!(YieldloveConsentController(id));
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(YieldloveConsentView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

}

class YieldloveConsentController {

  YieldloveConsentController(int id) : _channel = new MethodChannel('de.stroeer.plugins/consent_view_$id') {
    _channel.setMethodCallHandler(_handleMethod);
  }

  final MethodChannel _channel;
  ConsentEventListener? listener;

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

  static const Map<String, YieldConsentEvent> _methodToMobileAdEvent =
  <String, YieldConsentEvent>{
    'onAdInit': YieldConsentEvent.init,
    'onAdLoaded': YieldConsentEvent.loaded,
    'onAdRequestBuild': YieldConsentEvent.requestBuild,
    'onAdFailedToLoad': YieldConsentEvent.failedToLoad,
    'onAdOpened': YieldConsentEvent.opened,
    'onAdLeftApplication': YieldConsentEvent.leftApplication,
    'onAdClosed': YieldConsentEvent.closed,
  };
}

enum YieldConsentEvent {
  init,
  loaded,
  requestBuild,
  failedToLoad,
  opened,
  leftApplication,
  closed,
}

typedef void ConsentEventListener(YieldConsentEvent event);