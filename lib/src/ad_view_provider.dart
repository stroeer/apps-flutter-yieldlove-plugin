import 'package:AppsFlutterYieldloveSDK/src/yieldlove_android.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'base_yield_ad_view.dart';

class AdCreationParams {

  String adId;
  String adKeyword;
  String adContentUrl;
  List<AdSize> adSizes;

  AdCreationParams({@required this.adId, @required this.adSizes, this.adKeyword, this.adContentUrl});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_sizes': _adSizesToStringList()
    };
  }

  List<String> _adSizesToStringList() => adSizes.map((e) => '${e.width}x${e.height}').toList(); //.join(';')
}

class AdSize {
  int width;
  int height;

  AdSize(this.width, this.height);
}

class YieldloveAdView extends StatefulWidget {

  final AdCreationParams adParamsParcel;

  const YieldloveAdView({
    Key key,
    this.gestureRecognizers,
    this.adParamsParcel,
    /// TODO add adController that is passed once the ad view is created.
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
