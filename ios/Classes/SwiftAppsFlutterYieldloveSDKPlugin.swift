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
                Yieldlove.instance.appName = appId
            }
        }
        if call.method == "loadInterstitialAd" {
            //adViewController = AdViewController()
            let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
            
            var adSlotId: String? = nil
            if let args = call.arguments as? Dictionary<String, Any> {
                if let adId = args["ad_unit_id"] as? String {
                    adSlotId = adId
                }
            }
            
            if (adSlotId != nil) {
                print("YL: loading interstitial with adId '"+adSlotId!+"'.")
                Yieldlove.instance.interstitialAd(
                    AdSlotId: adSlotId!,
                    UIViewController: viewController,
                    Delegate: SwiftAppsFlutterYieldloveSDKPlugin.interstitialHelper
                )
            } else {
                print("YL: Cannot load interstitial without adId.")
            }
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
        print("YL: Init platform view")

        // adSlotId
        var adSlotId: String? = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let adId = argsAsDictionary["ad_id"] as? String {
                adSlotId = adId
                print("YL: Using adId '"+adSlotId!+"' for banner ad.")
            }
        }
        
        // contentUrl
        var adContentUrl: String? = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let contentUrl = argsAsDictionary["ad_content_url"] as? String {
                adContentUrl = contentUrl
                print("YL: Using adContentUrl '"+adContentUrl!+"' for banner ad.")
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
        print("YL: get view")
        return YieldloveView.adView
    }
}

class AdViewController: UIViewController, YLBannerViewDelegate {
    public func adViewDidReceiveAd(_ bannerView: YLBannerView) {
        //self.bann
        print("YL: Ad loaded")
        YieldloveView.adView.addBannerView(bannerView: bannerView.getBannerView())
            // This line is needed to resize ads that may come from Prebid
            //Yieldlove.instance.resizeBanner(banner: bannerView)
    }

    public func adView(
        _ bannerView: YLBannerView,
        didFailToReceiveAdWithError error: YieldloveRequestError
    ) {
        print("YL: Ad error: \(error)")
    }
    
    func getDfpRequest() -> DFPRequest {
        let request = DFPRequest()
        /*if contentURL != nil {
         request.contentURL = contentURL
       }
       if keywords != nil {
         request.customTargeting = keywords
       }*/
        return request
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
        print("YL: Failed to load interstitial. Error: "+error.description)
    }
}

class AdView: UIView {
    
    func addBannerView(bannerView: GADBannerView) {
        self.addSubview(bannerView)
    }
}
