import 'package:AppsFlutterYieldloveSDK/src/yieldlove_android.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../YieldloveWrapper.dart';
import 'base_yield_ad_view.dart';

class AdCreationParams {

  String adId;
  String adKeyword;
  String adContentUrl;
  List<AdSize> adSizes;
  bool adIsRelease = false;
  bool useTestAds = false;

  AdCreationParams({@required this.adId, @required this.adSizes, this.adKeyword, this.adContentUrl});

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
  final MobileAdListener listener;

  const YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    this.adParamsParcel,
    this.listener,
  })  : super(key: key);

  static BaseYieldAdView _adView;

  static BaseYieldAdView get view {
    if (_adView == null) {
      final  defaultTargetPlatform = TargetPlatform.android; // TODO arty
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _adView = AndroidYieldAdView();
          break;
        case TargetPlatform.iOS:
          _adView = AndroidYieldAdView(); // TODO arty
          break;
        default:
          throw UnsupportedError("Trying to use the default view implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _adView;
  }

  /// Which gestures should be consumed by our view.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _YieldloveAdViewState();
}

class _YieldloveAdViewState extends State<YieldloveAdView> {

  @override
  Widget build(BuildContext context) {
    return YieldloveAdView.view.build(
      context: context,
      gestureRecognizers: widget.gestureRecognizers,
      creationParams: widget.adParamsParcel,
      listener: widget.listener,
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
