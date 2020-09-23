import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';

// example data for yieldlove
/*const val YIELDLOVE_ACCOUNT_ID = "promoqui"
    const val YIELDLOVE_PROPERTY_NAME = "inapp.ios.test"
    const val YIELDLOVE_PROPERTY_ID = 6960
    const val YIELDLOVE_PRIVACY_MANAGER_ID = "114323"*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YieldloveWrapper.instance.initialize(appId: "promoqui").then((value) {
    print("app-widget: initialized = ${value}");
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
  Widget _yieldloveAdView;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Yieldlove native ad view:'),
              //YieldloveAdView(
              //    adParamsParcel: AdCreationParams(
              //      adId: 'rubrik_b2',
              //      adKeyword: null,
              //      adContentUrl: 'https://www.google.com',
              //      useTestAds: false,
              //      adIsRelease: false,
              //    ),
              //    onPlatformViewCreated: (YieldloveAdController controller) {
              //      controller.listener = (YieldAdEvent event) {
              //        print("BannerAd event $event");
              //      };
              //      controller.showAd();
              //    }
              //),
              Padding(
                padding: const EdgeInsets.only(top: 500),
                child: Text('bottom view'),
              ),
              RaisedButton(
                onPressed: () {
                  //val adUnitId = if (Config.USE_TEST_AD_TAGS) {
                  //    "/4444/m.app.dev.test/start_int"
                  //} else if (BuildConfig.BUILD_TYPE == "sdi") {
                  //    "/4444/m.app.droid_toi_sd/teststart_int"
                  //} else {
                  //    "/4444/m.app.droid_toi_sd/appstart_int"
                  //}
                  YieldloveWrapper.instance.showInterstitial(adUnitId: "/4444/m.app.dev.test/start_int");
                },
                child: Text("show interstitial"),
              ),
              FlatButton(
                  child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Title'),
                          //my color line
                          Container(
                            height: 5,
                            width: 100,
                            color: Colors.blue[800],
                          )
                        ],
                      ))
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getHeight(double screenHeight, BuildContext context, double size) {
    return (MediaQuery.of(context).size.height / screenHeight) * size;
  }
}