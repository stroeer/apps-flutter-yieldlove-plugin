import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
    _yieldloveAdView = YieldloveAdView(
      adParamsParcel: AdCreationParams(
          adId: 'rubrik_b1',
          //adSizes: [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
          adKeyword: null,
          adContentUrl: 'https://www.google.com',
          useTestAds: false,
          adIsRelease: false,
      ),
      onPlatformViewCreated: (YieldloveAdController controller) {
        _yieldloveAdController = controller;
        _yieldloveAdController.listener = (YieldAdEvent event) {
          print("BannerAd event $event");
        };
        _yieldloveAdController.showAd();
      }
    );
  }

  YieldloveAdController _yieldloveAdController;

  void _onReloadAd() {
    _yieldloveAdController.showAd();
  }

  double adHeight = 300;
  void _resizeAd(BuildContext context) {
    print("resized");
    adHeight = 305;
    print("app-widget: screen height=${MediaQuery.of(context).size.height}");
    setState(() {});
  }

  double getHeight(double screenHeight, BuildContext context, double size) {
    return (MediaQuery.of(context).size.height / screenHeight) * size;
  }

  YieldloveAdView createBannerAd() {
    return YieldloveAdView(
        adParamsParcel: AdCreationParams(
          adId: 'rubrik_b4',
          adKeyword: null,
          adContentUrl: 'https://www.google.com',
          useTestAds: false,
          adIsRelease: false,
        ),
        onPlatformViewCreated: (YieldloveAdController controller) {
          controller.listener = (YieldAdEvent event) {
            print("BannerAd event $event");
            if (event == YieldAdEvent.loaded) {
              controller.showAd();
            }
          };
        }
    );
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
              RaisedButton(
                onPressed: () {_resizeAd(context);},
                child: Text('Resize ad'),
              ),

             _yieldloveAdView,
              Padding(
                padding: const EdgeInsets.only(top: 500),
                child: Text('bottom view'),
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


  @override
  void dispose() {
    //_yieldloveAdView?.dispose();
    super.dispose();
  }

}