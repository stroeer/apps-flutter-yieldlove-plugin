import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

// example data for yieldlove
/*const val YIELDLOVE_ACCOUNT_ID = "promoqui"
    const val YIELDLOVE_PROPERTY_NAME = "inapp.ios.test"
    const val YIELDLOVE_PROPERTY_ID = 6960
    const val YIELDLOVE_PRIVACY_MANAGER_ID = "114323"*/

//const appId = "appDfpTest";
//const appId = 'promoqui';
const appId = 't-online_wetter_flutter';
//const appId = 't-online_wetter';

//const bannerAdId = 'banner';
const bannerAdId = 'start_b2';

//const interstitialAdId = 'interstitial';
const interstitialAdId = 'appstart_int';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YieldloveWrapper.instance.initialize(
      appId: appId,
      analyticsEnabled: false
  ).then((value) {
    print("app-widget: initialized = $value");
  }).catchError((e) {
    print("app-widget: failed with ${e.error}");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final adParams = AdCreationParams(
        adId: bannerAdId,
        optimalHeight: 250,
        optimalWidth: 300,
        adKeyword: null,
        adContentUrl: 'https://www.google.com',
        useTestAds: false,
        adIsRelease: false,
        customTargeting: {"testKey": "testValue"}
    );
    final adParams2 = AdCreationParams(
        adId: 'start_b4',
        optimalHeight: 250,
        optimalWidth: 300,
        adKeyword: null,
        useTestAds: false,
        adIsRelease: false,
    );

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _headline(context, 'Welcome to Yieldlove Wrapper SDK plugin for flutter!'),
                        _paragraph('You launched the app with app id "$appId".'),
                        _paragraph('Note, if you update the app id, deinstall the app and then install with new app id.',
                          padding: const EdgeInsets.only(top: 4),
                          style: TextStyle(fontStyle: FontStyle.italic)),
                        _headline(context, 'Consent Management'),
                        _paragraph('If an app should show personalized ads the '
                            'user must give his consent. This plugin provides '
                            'cmp features relying on the Sourcepoint SDK (not '
                            'the Yieldlove wrapper SDK beyond).',
                        ),
                        ElevatedButton(
                            onPressed: () {
                              YieldloveWrapper.instance.showConsentDialog();
                            },
                            child: Text("Show consent dialog")
                        ),
                        ElevatedButton(
                            onPressed: () {
                              YieldloveWrapper.instance.showConsentPrivacyManager();
                            },
                            child: Text("Show privacy manager")
                        ),

                        _headline(context, 'Interstitial Ads'),
                        _paragraph('Load interstitial ad with id "$interstitialAdId":'),
                        ElevatedButton(
                          onPressed: () {
                            YieldloveWrapper.instance
                                .showInterstitial(adUnitId: interstitialAdId);
                          },
                          child: Text("Show interstitial"),
                        ),

                        Container(
                          height: 332,
                          color: Colors.black26,
                          child: Center(
                            child: Text('Placeholder'),
                          ),
                        ),

                        _headline(context, 'Banner ads'),
                        _paragraph('Native ad with id "${adParams.adId}"'),
                        YieldloveAdView(
                            adParamsParcel: adParams,
                            placedInsideScrollView: true,
                            onPlatformViewCreated: (YieldloveAdController controller) {
                              controller.listener = (YieldAdEvent event) {
                                print("BannerAd event $event");
                              };
                              controller.showAd();
                            }
                        ),
                        Container(
                          height: 332,
                          color: Colors.black26,
                          child: Center(
                            child: Text('Werbung, die begeistert'),
                          ),
                        ),
                        _paragraph('And again: native ad with id "${adParams2.adId}"'),
                        YieldloveAdView(
                            adParamsParcel: adParams2,
                            placedInsideScrollView: true,
                            onPlatformViewCreated: (YieldloveAdController controller) {
                              controller.listener = (YieldAdEvent event) {
                                print("BannerAd event $event");
                              };
                              controller.showAd();
                            }
                        ),

                        Expanded(child: Container()),
                        Text('the bottom of the screen'),
                        const SizedBox(
                          height: 16,
                        )
                      ],
                    ),
                  ),
                )
            )
          );
        },
        ),
      ),
    );
  }

  Widget _paragraph(String text, {TextStyle style, EdgeInsets padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: style),
      ),
    );
  }

  Widget _headline(BuildContext context, String headline) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(headline,
            style: Theme.of(context).textTheme.headline5),
      ),
    );
  }
}