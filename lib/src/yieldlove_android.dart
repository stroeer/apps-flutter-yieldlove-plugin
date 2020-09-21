import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'base_yield_ad_view.dart';

class AndroidYieldAdView implements BaseYieldAdView {

  final Function onPlatformViewCreatedCallback;

  AndroidYieldAdView({this.onPlatformViewCreatedCallback});

  @override Widget build({
    BuildContext context,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    AdCreationParams creationParams
  }) {
    return GestureDetector(
      // intercept long press event.
      onLongPress: () {},
      excludeFromSemantics: true,
      child: AndroidView(
        viewType: 'de.stroeer.plugins/yieldlove_ad_view',
        onPlatformViewCreated: (int id) {
          if (onPlatformViewCreatedCallback != null) {
            onPlatformViewCreatedCallback();
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
