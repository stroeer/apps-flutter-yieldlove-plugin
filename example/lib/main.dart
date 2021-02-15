import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';

// example data for yieldlove
/*const val YIELDLOVE_ACCOUNT_ID = "promoqui"
    const val YIELDLOVE_PROPERTY_NAME = "inapp.ios.test"
    const val YIELDLOVE_PROPERTY_ID = 6960
    const val YIELDLOVE_PRIVACY_MANAGER_ID = "114323"*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YieldloveWrapper.instance.initialize(
      appId: "appDfpTest",
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


class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final adParams = AdCreationParams(
        adId: 'banner',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          YieldloveWrapper.instance.showInterstitial(adUnitId: "interstitial");
                        },
                        child: Text("Show interstitial"),
                      ),
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

                      Expanded(child: Container()),
                      Text('the bottom of the screen'),
                    ],
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