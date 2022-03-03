import Flutter
import UIKit
import YieldloveAdIntegration
import YieldloveConsent
import ConsentViewController
import GoogleMobileAds

public class SwiftAppsFlutterYieldloveSDKPlugin: NSObject, FlutterPlugin {

    static var adViews: [String:AdView] = [:]
    private static var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let instance = SwiftAppsFlutterYieldloveSDKPlugin()
        channel = FlutterMethodChannel(name: "AppsFlutterYieldloveSDK", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
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
            if let appId = args["appId"] as? String {
                Yieldlove.setup(appName: appId)
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
                    adSlotId: adSlotId!,
                    completion: { (interstitial, error) in
                        if let error = error {
                            print("YL: Failed to load interstitial. Error: \(error.localizedDescription)")
                            var dict: [String: Any] = [:]
                            dict["errorMessage"] = error.localizedDescription
                            SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("showInterstitialError", arguments: dict)
                            return
                        }
                        let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
                        interstitial?.present(fromRootViewController: viewController)
                        SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("didShowInterstitial", arguments: nil)
                    }
                )
            } else {
                print("YL: Cannot load interstitial without adId.")
            }
        }
        if call.method == "clearAdCache" {
            print("YL: clearAdCache")
            SwiftAppsFlutterYieldloveSDKPlugin.adViews.removeAll()
        }
        
        if call.method == "showPrivacyManager" {
            showPrivacyManager()
        }
        
        if call.method == "showConsent" {
            var authID: String? = nil
            if let args = call.arguments as? Dictionary<String, Any> {
                authID = args["authId"] as? String
            }
            showConsent(authID: authID)
        }

        result(true)
    }
    
    
    private func showPrivacyManager() {
        let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
        YieldloveConsent.instance.showPrivacyManager(viewController: viewController, delegate: self)
    }
    
    private func showConsent(authID: String?) {
        let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
        if let authID = authID {
            YieldloveConsent.instance.collect(viewController: viewController, delegate: self, authId: authID)
        } else {
            YieldloveConsent.instance.collect(viewController: viewController, delegate: self)
        }
    }
}

extension SwiftAppsFlutterYieldloveSDKPlugin: ConsentDelegate {
    
    public func onConsentReady(consents: SPUserData) {
        if let userConsent = consents.gdpr?.consents {
            
            var acceptedVendors: [String] = []
            let vendorGrants = userConsent.vendorGrants
            for key in vendorGrants.keys {
                if vendorGrants[key]?.granted ?? false {
                    acceptedVendors.append(key)
                }
            }
            
            var dict: [String: Any] = [:]
            dict["consentString"] = userConsent.euconsent
            dict["acceptedVendors"] = acceptedVendors
            dict["acceptedCategories"] = userConsent.acceptedCategories
            //dict["legIntCategories"] = userConsent.acceptedCategories
            //dict["specialFeatures"] = userConsent.specialFeatures
            SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("onConsentReady", arguments: dict)
        }
    }
    
    public func consentUIDidDisappear() {
        SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("onConsentUIFinished", arguments: nil)
    }

    public func onError(error: YieldloveConsentError) {
        SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("onError", arguments: error.errorDescription)
    }
    
    public func gdprConsentUIWillShow() {
        SwiftAppsFlutterYieldloveSDKPlugin.channel?.invokeMethod("onConsentUIReady", arguments: nil)
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
    var adView: AdView?
    var adContentUrl: String?
    var adCustomTargeting: [String : String]?
    var adViewController: AdViewController? = nil
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
        
        // adSlotId
        var adSlotId: String? = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let adId = argsAsDictionary["ad_id"] as? String {
                adSlotId = adId
                if !adIsRelease {
                    print("YL: Using adId '\(adSlotId!)' for banner ad.")
                }
            }
        }
        
        // contentUrl
        adContentUrl = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let contentUrl = argsAsDictionary["ad_content_url"] as? String {
                adContentUrl = contentUrl
                if !adIsRelease {
                    //print("YL: Using adContentUrl '\(adContentUrl!)' for banner ad.")
                }
            }
        }
        
        // contentUrl
        adCustomTargeting = nil
        if let argsAsDictionary = args as? Dictionary<String, Any> {
            if let customTargeting = argsAsDictionary["custom_targeting"] as? [String : String]? {
                adCustomTargeting = customTargeting
                if !adIsRelease {
                    //print("YL: Using this key-value map for banner ad: \(customTargeting!)")
                }
            }
        }
        
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        super.init()
        guard adSlotId != nil else {
            return
        }
        adView = createAndStoreAdViewIfNecessaryFor(adSlotId: adSlotId!)
    }

    private func createAndStoreAdViewIfNecessaryFor(adSlotId: String) -> AdView {
        guard SwiftAppsFlutterYieldloveSDKPlugin.adViews[adSlotId] == nil else {
            return SwiftAppsFlutterYieldloveSDKPlugin.adViews[adSlotId]!
        }
        let adView = AdView()
        adViewController = AdViewController(
            contentUrl: adContentUrl,
            keywords: adCustomTargeting,
            adIsRelease: adIsRelease,
            adView: adView
        )
        SwiftAppsFlutterYieldloveSDKPlugin.adViews[adSlotId] = adView
        Yieldlove.instance.bannerAd(
            adSlotId: adSlotId,
            viewController: adViewController!,
            delegate: adViewController!
        )
        return adView
    }
    
    public func view() -> UIView {
        // TODO: Use optimal width (like optimal height)
        //let view = UIView(frame: CGRect(
        //                    x: 0,
        //                    y: 0, width: 100, height: 20))
        //view.backgroundColor = .blue
        //return view
        
        //YieldloveView.adView.center = CGPoint(x: adPositionX, y: 0)
        return adView ?? AdView()
    }
}

class AdViewController: UIViewController, YLBannerViewDelegate {
    
    var contentUrl: String?
    var keywords: [String : String]?
    var adIsRelease: Bool = true
    var adView: AdView?
    
    init(contentUrl: String?, keywords: [String : String]?, adIsRelease: Bool, adView: AdView) {
        self.contentUrl = contentUrl
        self.keywords = keywords
        self.adIsRelease = adIsRelease
        self.adView = adView
        super.init(nibName: nil, bundle: nil)
    }
    
    // Xcode 7 & 8
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func bannerViewDidReceiveAd(_ bannerView: YLBannerView) {
        if !adIsRelease {
            //print("YL: Ad loaded")
        }
        if let adView = adView {
            adView.addBannerView(bannerView: bannerView.getBannerView())
        }
        // This line is needed to resize ads that may come from Prebid
        //Yieldlove.instance.resizeBanner(banner: bannerView)
    }
    
    public func bannerView(
        _ bannerView: YLBannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        print("YL: Ad error: \(error)")
    }
    
    func getGAMRequest() -> GAMRequest {
        let request = GAMRequest()
        if contentUrl != nil {
            request.contentURL = contentUrl
        }
        if keywords != nil {
            request.customTargeting = keywords
        }
        return request
    }
}

// YLInterstitialDelegate removed in 5.0.0. See release notes: https://stroeerdigitalgroup.atlassian.net/wiki/spaces/SDGPUBLIC/pages/1890713878/iOS+integration+documentation#Change-log
//class YLInterstitialHelper: YLInterstitialDelegate {
//    public func interstitialDidReceiveAd(_ ad: YLInterstitial) {   // error: cannot find type 'YLInterstitial' in scope
//        if (ad.getInterstitial().isReady) {
//            let viewController = UIApplication.shared.windows.first!.rootViewController ?? UIViewController()
//            ad.getInterstitial().present(fromRootViewController: viewController)
//        }
//    }
//
//    // cannot find type 'YLInterstitial' in scope
//    public func interstitial(_ interstitial: YLInterstitial, didFailToReceiveAdWithError error: YieldloveRequestError) {  // cannot find type 'YieldloveRequestError' in scope
//        print("YL: Failed to load interstitial. Error: \(error.description)")
//    }
//}

class AdView: UIView {
    
    func addBannerView(bannerView: GADBannerView) {
        self.addSubview(bannerView)
    }
}
