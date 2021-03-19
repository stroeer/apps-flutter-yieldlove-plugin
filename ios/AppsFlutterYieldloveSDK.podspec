#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint AppsFlutterYieldloveSDK.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'AppsFlutterYieldloveSDK'
  s.version          = '0.9.9'
  s.summary          = 'A flutter plugin for Yieldlove SDK. (iOS podspec file)'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'YieldloveAdIntegration', '3.0.1'
  s.static_framework = true
  s.ios.deployment_target = '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
