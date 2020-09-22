import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';
import 'package:AppsFlutterYieldloveSDK/src/ad_view_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YieldloveWrapper.instance.initialize(appId: "t-online").then((value) {
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
    initPlatformState();
    _yieldloveAdView = YieldloveAdView(
      adParamsParcel: AdCreationParams(
          adId: 'rubrik_b1',
          adSizes: [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
          adKeyword: null,
          adContentUrl: 'https://www.google.com',
          useTestAds: true,
          adIsRelease: false,
      ),
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
      onPlatformViewCreated: (YieldloveAdController controller) {
        _yieldloveAdController = controller;
        controller.showAd();
      }
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = 'undefined';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
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
                onPressed: _onReloadAd,
                child: Text('Reload ad'),
              ),
              RaisedButton(
                onPressed: () {_resizeAd(context);},
                child: Text('Resize ad'),
              ),
              SizedBox(
                width: double.infinity,
                height: adHeight,
                child: _yieldloveAdView,
              ),

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