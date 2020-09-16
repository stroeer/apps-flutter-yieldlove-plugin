#import "AppsFlutterYieldloveSDKPlugin.h"
#if __has_include(<AppsFlutterYieldloveSDK/AppsFlutterYieldloveSDK-Swift.h>)
#import <AppsFlutterYieldloveSDK/AppsFlutterYieldloveSDK-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "AppsFlutterYieldloveSDK-Swift.h"
#endif

@implementation AppsFlutterYieldloveSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppsFlutterYieldloveSDKPlugin registerWithRegistrar:registrar];
}
@end
