# AppsFlutterYieldloveSDK

A new flutter plugin project.

Note, in version 0.0.1 of the Flutter lib only Android is supported. Feedback much appreciated.

## Getting started with Flutter

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Integration steps

Import the preview lib to your `pubspec.yaml`:
```yaml
sdks:
  ...
  AppsFlutterYieldloveSDK:
    git:
      url: https://github.com/stroeer/apps-flutter-yieldlove-plugin.git
```

Inside `main.dart`:
```dart
import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';

void main() async {
  await YieldloveWrapper.instance.initialize(appId: "promoqui").then((value) {
    print("app-widget: initialized = ${value}");
  });
  runApp(MyApp());
}
```

Inside a Flutter widget:
```dart
import 'package:AppsFlutterYieldloveSDK/YieldloveWrapper.dart';

YieldloveAdView(
  adParamsParcel: AdCreationParams(
    adId: 'rubrik_b2',
    adKeyword: null,
    adContentUrl: 'https://www.google.com',
    useTestAds: false,
    adIsRelease: false,
  ),
  onPlatformViewCreated: (YieldloveAdController controller) {
    controller.listener = (YieldAdEvent event) {
      print("BannerAd event: $event");
    };
    controller.showAd();
  }
)
```