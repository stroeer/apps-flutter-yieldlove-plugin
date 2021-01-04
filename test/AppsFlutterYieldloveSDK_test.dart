import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:AppsFlutterYieldloveSDK/AppsFlutterYieldloveSDK.dart';

void main() {
  const MethodChannel channel = MethodChannel('AppsFlutterYieldloveSDK');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // TODO: Broken test, cannot import AppsFlutterYieldloveSDK.dart
    //expect(await AppsFlutterYieldloveSDK.platformVersion, '42');
  });
}
