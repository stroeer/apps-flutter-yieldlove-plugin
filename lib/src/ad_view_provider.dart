import 'package:AppsFlutterYieldloveSDK/src/yieldlove_android.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'abstract_view_platform.dart';

class AdParamsParcel {
  String one;
  String two;

  AdParamsParcel({this.one, this.two});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'one': this.one,
      'two': this.two,
    };
  }
}
class YieldloveAdView extends StatefulWidget {

  final AdParamsParcel adParamsParcel;

  const YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    this.adParamsParcel,
    /// TODO add adController that is passed once the ad view is created.
  })  : super(key: key);

  static ViewPlatform _platform;

  static set platform(ViewPlatform platform) {
    _platform = platform;
  }

  static ViewPlatform get platform {
    if (_platform == null) {
      final  defaultTargetPlatform = TargetPlatform.android; // TODO arty
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidYieldloveAdView();
          break;
        case TargetPlatform.iOS:
          _platform = AndroidYieldloveAdView(); // TODO arty
          break;
        default:
          throw UnsupportedError("Trying to use the default view implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _platform;
  }

  /// Which gestures should be consumed by our view.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();
}

class _YieldloveAdViewState extends State<YieldloveAdView> {

  @override
  Widget build(BuildContext context) {
    return YieldloveAdView.platform.build(
      context: context,
      gestureRecognizers: widget.gestureRecognizers,
      params: widget.adParamsParcel,
    );
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
