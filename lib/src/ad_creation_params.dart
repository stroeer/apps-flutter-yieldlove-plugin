import 'package:AppsFlutterYieldloveSDK/src/ad_size.dart';

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

  List<AdSize> _optimalAdSizes = []; // is calculated based on adId

  AdCreationParams({
    required this.adId,
    this.adKeyword,
    this.adContentUrl,
    this.adSizes,
    this.useTestAds = false,
    this.adIsRelease = false
  }) {
    if (adSizes != null) {
      print(adSizes);
      assert(adSizes!.isNotEmpty, 'The adSizes list should never be empty!');
    } //else {
      _optimalAdSizes =
          _mapAdTypeToAdSize[this.adId] ?? [AdSize(width: 300, height: 150)];
      //print("app-widget: optimalAdSizes=${optimalAdSizes.first.height}");
    //}
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_sizes': _adSizesToStringList(adSizes ?? _optimalAdSizes),
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
    this._optimalAdSizes = adSizes;
    return adSizes.map((e) => '${e.width}x${e.height}').toList();
  }

  double getOptimalHeight() => (adSizes ?? _optimalAdSizes).first.height.toDouble();
}