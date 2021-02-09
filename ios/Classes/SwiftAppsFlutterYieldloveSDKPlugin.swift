import Flutter
import UIKit
import YieldloveAdIntegration
import GoogleMobileAds

public class SwiftAppsFlutterYieldloveSDKPlugin: NSObject, FlutterPlugin {
    static let interstitialHelper = YLInterstitialHelper()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
    
    let instance = SwiftAppsFlutterYieldloveSDKPlugin()
    let channel = FlutterMethodChannel(name: "AppsFlutterYieldloveSDK", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)

    // dummy stubs to avoid crashing; should be moved to the native view factory or into corresponding native views
    let channel2 = FlutterMethodChannel(name: "de.stroeer.plugins/adview_0", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel2)

    registrar.register(YieldloveViewFactory(with: registrar), withId: "de.stroeer.plugins/yieldlove_ad_view")
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //var adViewController: AdViewController? = nil
        //Yieldlove.instance.interstitialAd(AdUnit: "example_ios_interstitial_1", UIViewController: self)
        if let args = call.arguments as? Dictionary<String, Any> {
            if let appId = args["appId"] as? String {
                // TODO apparently native Yieldlove SDK for iOS doesn't not have
                // TODO this property ("appName") anymore; test ads work fine without it
                // Yieldlove.instance.appName = appId
            }
        }
        if call.method == "loadInterstitialAd" {
            //adViewController = AdViewController()
            let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
            Yieldlove.instance.interstitialAd(
                AdSlotId: "/4444/m.app.ios_toi_sd/appstart_int",
                UIViewController: viewController,
                Delegate: SwiftAppsFlutterYieldloveSDKPlugin.interstitialHelper
            )
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
        return YieldloveView(frame, viewId: viewId, args: args, registrar: registrar)
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
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

        var adSlotId: String? = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let adId = argsAsDictionary["ad_id"] as? String {
                adSlotId = adId
            }
        }
       
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        super.init()
        guard adSlotId != nil else {
            return
        }
        adViewController = AdViewController()
        Yieldlove.instance.bannerAd(
            AdSlotId: adSlotId!,
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

class YLInterstitialHelper: YLInterstitialDelegate {
    public func interstitialDidReceiveAd(_ ad: YLInterstitial) {
        if (ad.getInterstitial().isReady) {
            let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
            ad.getInterstitial().present(fromRootViewController: viewController)
        }
    }
    
    public func interstitial(_ interstitial: YLInterstitial, didFailToReceiveAdWithError error: YieldloveRequestError) {
        print(error)
    }
}

class AdView: UIView {
    
    func addBannerView(bannerView: GADBannerView) {
        self.addSubview(bannerView)
    }
}
