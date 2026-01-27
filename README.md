# Red5WebRTCKit

Build low-latency live streaming apps with the Red5 iOS WebRTC SDK.

## Installation

### Swift Package Manager

Add Red5WebRTCKit to your project:

1. In Xcode: **File → Add Package Dependencies**
2. Enter: `https://github.com/red5pro/red5pro-ios-sdk`
3. Select version: **1.0.0-release.b1.red5cloud**
4. Add `Red5WebRTCKit` to your target

## Usage

```swift
import Red5WebRTCKit
import WebRTC

// Create video renderer
let videoRenderer = RTCMTLVideoView()

// Configure and build client
let client = Red5WebrtcClientBuilder()
    .setStreamManagerHost("your-host.cloud.red5.net")
    .setPort(443)
    .setAppName("live")
    .setStreamName("myStream")
    .setLicenseKey("your-license-key")
    .setVideoEnabled(true)
    .setAudioEnabled(true)
    .setEventListener(self)
    .build()

// Set renderer and start
client.setVideoRenderer(videoRenderer)
client.startPreview()
client.publish()
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

## Dependencies

Automatically included:
- [WebRTC](https://github.com/stasel/WebRTC) (140.0.0+)
- [PubNub](https://github.com/pubnub/swift) (10.0.1+) - for Red5PubNubClient only

## License

See [LICENSE](LICENSE) file.
