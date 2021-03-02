import 'dart:io';

import 'package:flutter/foundation.dart';

class Build {

  static const bool isDebug = kDebugMode;

  static const bool isRelease = kReleaseMode;

}

// ignore: avoid_classes_with_only_static_members
class Environment {

  /// Whether the environment is of type
  /// [WebBrowser](https://en.wikipedia.org/wiki/Web_browser).
  static final bool isWebBrowser = kIsWeb;

  /// Whether the environment is of type
  /// [iOS](https://en.wikipedia.org/wiki/IOS).
  static final bool isIOS = !isWebBrowser && Platform.isIOS;

  /// Whether the environment is of type
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29).
  static final bool isAndroid = !isWebBrowser && Platform.isAndroid;

}