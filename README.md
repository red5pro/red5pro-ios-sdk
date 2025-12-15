# Red5WebRTCKit

Build low-latency live streaming apps with the Red5 iOS WebRTC SDK.

## Installation

### Swift Package Manager

Add Red5WebRTCKit to your project:

1. In Xcode: File > Add Package Dependencies
2. Enter the repository URL
3. Select version/branch
4. Add to your target

The dependencies (WebRTC) will be automatically resolved.

## Usage

```swift
// Import the package (this brings in Red5WebRTCKit, WebRTC)
import Red5WebRTCKit
import WebRTC

// Create video renderer
let videoRenderer = RTCMTLVideoView()

// Configure client
let client = Red5WebrtcClientBuilder()
    .setStreamManagerHost("your-host.cloud.red5.net")
    .setPort(443)
    .setAppName("live")
    .setStreamName("myStream")
    .setVideoEnabled(true)
    .setAudioEnabled(true)
    .setEventListener(self)
    .build()

// Set renderer
client.setVideoRenderer(videoRenderer)

// Start preview
client.startPreview()

// Publish
client.publish()
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Dependencies

This package automatically includes:
- WebRTC (140.0.0)

## License

[see license](LICENSE)
