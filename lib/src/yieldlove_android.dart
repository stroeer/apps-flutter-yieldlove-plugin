import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'abstract_view_platform.dart';

class AndroidYieldloveAdView implements ViewPlatform {

  @override
  Widget build({
    BuildContext context,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    AdParamsParcel params
  }) {
    return GestureDetector(
      // intercept long press event.
      onLongPress: () {},
      excludeFromSemantics: true,
      child: AndroidView(
        viewType: 'de.stroeer.plugins/yieldlove_ad_view',
        onPlatformViewCreated: (int id) {

        },
        gestureRecognizers: gestureRecognizers,
        layoutDirection: TextDirection.rtl,
        creationParams: params.toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

}
