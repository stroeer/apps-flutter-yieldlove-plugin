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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
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

    setState(() {
      _platformVersion = platformVersion;
      _yieldloveAdController = YieldloveAdController._(0);
    });
  }

  YieldloveAdController _yieldloveAdController;

  void _onLoadAd() {
    _yieldloveAdController.showAd();
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
              Center(
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      width: 300.0,
                      height: 300.0,
                      child: YieldloveAdView(
                        adParamsParcel: AdCreationParams('rubrik_b3',
                            adKeyword: null,
                            adSizes: [AdSize(320, 50), AdSize(320, 75), AdSize(320, 150), AdSize(300, 250), AdSize(37, 31)],
                            adContentUrl: 'https://www.google.com'
                        ),
                        // TODO pass controller
                      ),
                  )
              ),
              RaisedButton(onPressed: _onLoadAd, child:
                Text('Load ad'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 500),
                child: Text('bottom view'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YieldloveAdController {
  YieldloveAdController._(int id) : _channel = new MethodChannel('de.stroeer.plugins/adview_$id');

  final MethodChannel _channel;

  Future<void> showAd() async {
    return _channel.invokeMethod('showAd');
  }

  Future<void> hideAd() async {
    return _channel.invokeMethod('hideAd');
  }
}