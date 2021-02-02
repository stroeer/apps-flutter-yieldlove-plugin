import 'package:AppsFlutterYieldloveSDK/src/ad_size.dart';

class AdCreationParams {

  final String adId;
  final String? adKeyword;
  final String? adContentUrl;
  final bool? adIsRelease;
  final bool? useTestAds;

  final double? optimalHeight;

  AdCreationParams({
    required this.adId,
    this.adKeyword,
    this.adContentUrl,
    this.optimalHeight,
    this.useTestAds = false,
    this.adIsRelease = false
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ad_id': this.adId,
      'ad_keyword': this.adKeyword,
      'ad_content_url': this.adContentUrl,
      'ad_is_release': adIsRelease,
      'use_test_ads': useTestAds,
    };
  }

  static const Map<String, List<AdSize>> _mapAdTypeToAdSize =
  <String, List<AdSize>>{
    //'all': [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
    'rubrik_b1': [AdSize(width: 300, height: 250), AdSize(width: 37, height: 31)],
    'rubrik_b2': [AdSize(width: 320, height: 150), AdSize(width: 37, height: 32)],
    'rubrik_b3': [AdSize(width: 320, height: 50), AdSize(width: 37, height: 33)],
    'rubrik_b4': [AdSize(width: 320, height: 75), AdSize(width: 37, height: 34)],
    'rubrik_b5': [AdSize(width: 37, height: 31), AdSize(width: 37, height: 35)],
    'm.app.dev.test/start_b1': [AdSize(width: 320, height: 75), AdSize(width: 37, height: 31)]
  };

  double getOptimalHeight() => optimalHeight ?? 250;
}