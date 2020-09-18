import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

abstract class ViewPlatform {

  Widget build({
    BuildContext context,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    AdParamsParcel params,
  });

}