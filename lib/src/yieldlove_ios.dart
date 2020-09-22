import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'base_yield_ad_view.dart';

class IosYieldAdView implements BaseYieldAdView {

  final Function onPlatformViewCreatedCallback;

  IosYieldAdView({this.onPlatformViewCreatedCallback});

  @override Widget build({
    BuildContext context,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    AdCreationParams creationParams,
    AdEventListener listener,
  }) {
    return GestureDetector(
      // intercept long press event.
      onLongPress: () {},
      excludeFromSemantics: true,
      child: UiKitView(
        viewType: 'de.stroeer.plugins/yieldlove_ad_view',
        onPlatformViewCreated: (int id) {
          if (onPlatformViewCreatedCallback != null) {
            onPlatformViewCreatedCallback(id);
          }
        },
        gestureRecognizers: gestureRecognizers,
        layoutDirection: TextDirection.rtl,
        creationParams: creationParams.toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

}
