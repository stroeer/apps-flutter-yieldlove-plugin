import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

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
const bannerAdId = 'start_b4';

const interstitialAdId = 'interstitial';
//const interstitialAdId = 'appstart_int';

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
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  SourcepointCmp _sourcepointCmp;

  @override
  void initState() {
    // http://cdn.stroeerdigitalgroup.de/sdk/live/t-online_wetter_flutter/config.json
    _sourcepointCmp = SourcepointCmp(
        accountId: 375, // always the same for Ströer
        propertyId: 10452,
        propertyName: "android.app.wetter.info",
        pmId: "179267",
        onConsentReady: () {
          print('consentReady');
        },
        onError: (errorCode) {
          print('consentError: errorCode:$errorCode');
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adParams = AdCreationParams(
        adId: bannerAdId,
        optimalHeight: 100,
        adKeyword: null,
        adContentUrl: 'https://www.google.com',
        useTestAds: false,
        adIsRelease: false,
        customTargeting: {"testKey": "testValue"}
    );
    return MaterialApp(
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
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Load interstitial ad with id "$interstitialAdId":'),
                        RaisedButton(
                          onPressed: () {
                            YieldloveWrapper.instance.showInterstitial(adUnitId: interstitialAdId);
                          },
                          child: Text("Show interstitial"),
                        ),
                        const SizedBox(height: 32),
                        Text('Native ad with id "${adParams.adId}":'),
                        YieldloveAdView(
                            adParamsParcel: adParams,
                            onPlatformViewCreated: (YieldloveAdController controller) {
                              controller.listener = (YieldAdEvent event) {
                                print("BannerAd event $event");
                              };
                              controller.showAd();
                            }
                        ),

                        RaisedButton(
                          onPressed: () {
                            _sourcepointCmp.load();

                            YieldloveWrapper.instance.

                            //_sourcepointCmp.showPM();

                            //YieldloveWrapper.instance.showConsent();

                          },
                          child: Text("Show consent dialog")
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

  double getHeight(double screenHeight, BuildContext context, double size) {
    return (MediaQuery.of(context).size.height / screenHeight) * size;
  }
}