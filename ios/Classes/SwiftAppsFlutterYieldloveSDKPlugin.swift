import Flutter
import UIKit
import YieldloveAdIntegration
import GoogleMobileAds

// TODO best example I found so far: https://github.com/kmcgill88/admob_flutter/tree/master/ios

public class SwiftAppsFlutterYieldloveSDKPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    Yieldlove.instance.appName = "promoqui";
    let instance = SwiftAppsFlutterYieldloveSDKPlugin()
    let channel = FlutterMethodChannel(name: "AppsFlutterYieldloveSDK", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)

    // dummy stubs to avoid crashing; should be moved to the native view factory or into corresponding native views
    let channel2 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_0", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel2)

    registrar.register(YieldloveViewFactory(with: registrar), withId: "de.stroeer.plugins/yieldlove_ad_view")
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      //Yieldlove.instance.interstitialAd(AdUnit: "example_ios_interstitial_1", UIViewController: self)
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
        return YieldloveView(frame, viewId: viewId, args: args, registrar: registrar)
    }
}

public class YieldloveView: NSObject, FlutterPlatformView {
    let registrar: FlutterPluginRegistrar
    let frame: CGRect
    let viewId: Int64
    static var adView = AdView()
    var adViewController: AdViewController? = nil
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        print("YL init platform view")
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        super.init()
        adViewController = AdViewController()

        Yieldlove.instance.bannerAd(
            AdSlotId: "rubrik_b2",
            UIViewController: adViewController!,
            Delegate: adViewController!
        )
    }

    public func view() -> UIView {
        print("YL getView")
        return YieldloveView.adView
    }
}

class AdViewController: UIViewController, YLBannerViewDelegate {
    public func adViewDidReceiveAd(_ bannerView: YLBannerView) {
        //self.bann
        print("YL ad loaded")
        YieldloveView.adView.addBannerView(bannerView: bannerView.getBannerView())
            // This line is needed to resize ads that may come from Prebid
            //Yieldlove.instance.resizeBanner(banner: bannerView)
        }

        public func adView(
            _ bannerView: YLBannerView,
            didFailToReceiveAdWithError error: YieldloveRequestError
        ) {
            print("YL ad error: \(error)")
        }
}

class AdView: UIView {
    
    func addBannerView(bannerView: GADBannerView) {
        self.addSubview(bannerView)
    }
}
