import 'package:AppsFlutterYieldloveSDK/src/ad_size.dart';

class AdCreationParams {

  final String adId;

  /// addCustomTargeting("keywords", adKeyword)
  final String? adKeyword;

  final String? adContentUrl;

  /// addOnAdClickListener is only called for non-release versions.
  /// For non-release versions there are also more prints on terminal.
  final bool? adIsRelease;

  /// If set to true, you should always see an ad.
  /// How it works? -> Custom targeting ("demo" to "mobileads") is added.
  final bool? useTestAds;

  /// define the height of the ad (dynamic height is not supported yet)
  final double? optimalHeight;

  final Map<String, String>? customTargeting;

  AdCreationParams({
    required this.adId,
    this.adKeyword,
    this.adContentUrl,
    this.optimalHeight,
    this.useTestAds = false,
    this.adIsRelease = false,
    this.customTargeting = const {}
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_is_release': adIsRelease,
      'use_test_ads': useTestAds,
      //'customTargeting': customTargeting,
    };
  }

  /*static const Map<String, List<AdSize>> _mapAdTypeToAdSize =
  <String, List<AdSize>>{
    //'all': [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
    'rubrik_b1': [AdSize(width: 300, height: 250), AdSize(width: 37, height: 31)],
    'rubrik_b2': [AdSize(width: 320, height: 150), AdSize(width: 37, height: 32)],
    'rubrik_b3': [AdSize(width: 320, height: 50), AdSize(width: 37, height: 33)],
    'rubrik_b4': [AdSize(width: 320, height: 75), AdSize(width: 37, height: 34)],
    'rubrik_b5': [AdSize(width: 37, height: 31), AdSize(width: 37, height: 35)],
    'm.app.dev.test/start_b1': [AdSize(width: 320, height: 75), AdSize(width: 37, height: 31)]
  };*/

  double getOptimalHeight() => optimalHeight ?? 250;
}