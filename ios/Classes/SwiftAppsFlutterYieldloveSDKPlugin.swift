import Flutter
import UIKit
import YieldloveAdIntegration

// TODO best example I found so far: https://github.com/kmcgill88/admob_flutter/tree/master/ios

public class SwiftAppsFlutterYieldloveSDKPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAppsFlutterYieldloveSDKPlugin()
    let channel = FlutterMethodChannel(name: "AppsFlutterYieldloveSDK", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)

    // dummy stubs to avoid crashing; should be moved to the native view factory or into corresponding native views
    let channel2 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_0", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel2)

    registrar.register(NativeTextFieldFactory(with: registrar), withId: "de.stroeer.plugins/yieldlove_ad_view")
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      //Yieldlove.instance.interstitialAd(AdUnit: "example_ios_interstitial_1", UIViewController: self)
      result(true)
    }
}

public class NativeTextFieldFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar

    init(with registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeTextField(frame, viewId: viewId, args: args, registrar: registrar)
    }
}

public class NativeTextField: NSObject, FlutterPlatformView {
    let registrar: FlutterPluginRegistrar
    let frame: CGRect
    let viewId: Int64
    let textField: UITextField

    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        self.textField = UITextField(frame: frame)
        self.textField.text = " 👋 Hallo Patrick 👋 "
        super.init()
    }

    public func view() -> UIView {
        return textField
    }
}
