Pod::Spec.new do |s|
  s.name             = 'Red5WebRTCKit'
  s.version          = '1.0.0-release.b1.red5cloud'
  s.summary          = 'Red5 Pro iOS WebRTC SDK'
  s.description      = <<-DESC
    Build low-latency live streaming apps with the Red5 iOS WebRTC SDK.
    Supports publishing, subscribing, and conferencing with WebRTC.
  DESC

  s.homepage         = 'https://www.red5.net'
  s.license          = { :type => 'Commercial', :file => 'LICENSE' }
  s.author           = { 'Red5 Pro' => 'support@red5.net' }
  
  # Source location - auto-updated by setup-distribution-simple.sh
  s.source           = { 
    :http => 'https://github.com/red5pro/red5pro-ios-sdk/releases/download/1.0.0-release.b1.red5cloud/Red5WebRTCKit-1.0.0-release.b1.red5cloud.xcframework.zip'
  }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'

  # The XCFramework (dynamic framework)
  s.vendored_frameworks = 'Red5WebRTCKit.xcframework'

  # Dependencies - uses stasel/WebRTC (same as SPM)
  s.dependency 'WebRTC-SDK', '~> 140.0'
  # s.dependency 'PubNubSwift', '~> 10.0'  # If using Red5PubNubClient

  # Required system frameworks
  s.frameworks = [
    'Foundation',
    'UIKit', 
    'AVFoundation',
    'CoreMedia',
    'CoreGraphics',
    'QuartzCore',
    'AudioToolbox',
    'CoreAudio'
  ]
  
  s.libraries = 'c++'

  # Build settings
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
