import Flutter
import UIKit

public class SwiftAppsFlutterYieldloveSDKPlugin: NSObject, FlutterPlugin {


    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let instance = SwiftAppsFlutterYieldloveSDKPlugin()
        let channel = FlutterMethodChannel(name: "AppsFlutterYieldloveSDK", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // dummy stubs to avoid crashing; should be moved to the native view factory or into corresponding native views
        let channel0 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_0", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel0)
        let channel1 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_1", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel1)
        let channel2 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_2", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel2)
        let channel3 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_3", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel3)
        let channel4 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_4", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel4)
        let channel5 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_5", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel5)

        registrar.register(YieldloveViewFactory(with: registrar), withId: "de.stroeer.plugins/yieldlove_ad_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //var adViewController: AdViewController? = nil
        //Yieldlove.instance.interstitialAd(AdUnit: "example_ios_interstitial_1", UIViewController: self)
        if let args = call.arguments as? Dictionary<String, Any> {
            if let appId = "dfdfasf" as? String {
            }
        }
        if call.method == "loadInterstitialAd" {

        }
        if call.method == "clearAdCache" {

        }
        result(true)
    }
}

public class YieldloveViewFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    
    init(with registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return YieldloveView(
            frame,
            viewId: viewId,
            args: args,
            registrar: registrar
        )
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class YieldloveView: NSObject, FlutterPlatformView {
    let registrar: FlutterPluginRegistrar
    let frame: CGRect
    let viewId: Int64
    var adContentUrl: String?
    var adCustomTargeting: [AnyHashable : Any]?
    var adIsRelease: Bool = true
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        // ad_is_release
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let isRelease = argsAsDictionary["ad_is_release"] as? Bool {
                adIsRelease = isRelease
            }
        }
        
        if !adIsRelease {
            //print("YL: Not a release version")
        }
        
        if !adIsRelease {
            //print("YL: Init platform view")
        }
        


        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        super.init()

    }

    private func createAndStoreAdViewIfNecessaryFor(adSlotId: String) -> UIView {

        let adView = view()

        return adView
    }
    
    public func view() -> UIView {
        // TODO: Use optimal width (like optimal height)
        let view = UIView(frame: CGRect(
                            x: 0,
                            y: 0, width: 100, height: 1))
        return view
        
        //YieldloveView.adView.center = CGPoint(x: adPositionX, y: 0)
    }
}

