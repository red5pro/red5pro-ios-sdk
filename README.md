# Red5 iOS WebRTC SDK

## Introduction

Build low-latency live streaming apps with the Red5 iOS WebRTC SDK. Stream video using WebRTC, and subscribe (play) streams via WebRTC. Compatible with both Red5Pro Cloud (Stream Manager) and standalone Red5Pro servers.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
4. [Requirements](#requirements)
5. [Quick Start](#quick-start)
6. [Usage](#usage)
   - 6.1 [Publishing to Red5 Cloud and Standalone with WebRTC](#publishing-to-red5-cloud-and-standalone-with-webrtc)
      - 6.1.1 [Step 1: Import the SDK](#step-1-import-the-sdk)
      - 6.1.2 [Step 2: Request Publish Permissions](#step-2-request-publish-permissions)
      - 6.1.3 [Step 3: Create Red5WebrtcClient object with Red5WebrtcClientBuilder()](#step-3-create-red5webrtcclient-object-with-red5webrtcclientbuilder)
      - 6.1.4 [Step 4: Setup Video Renderer](#step-4-setup-video-renderer)
      - 6.1.5 [Step 5: Start Preview](#step-5-start-preview)
      - 6.1.6 [Step 6: Start Publishing](#step-6-start-publishing)
   - 6.2 [Subscribing to Red5 Cloud and Standalone Streams with WebRTC](#subscribing-to-red5-cloud-and-standalone-streams-with-webrtc)
      - 6.2.1 [Step 1: Import the SDK](#step-1-import-the-sdk-1)
      - 6.2.2 [Step 2: Create Red5WebrtcClient object with Red5WebrtcClientBuilder()](#step-2-create-red5webrtcclient-object-with-red5webrtcclientbuilder)
      - 6.2.3 [Step 3: Setup Video Renderer](#step-3-setup-video-renderer)
      - 6.2.4 [Step 4: Start Subscribing](#step-4-start-subscribing)
7. [Listening For Events](#listening-for-events)
   - 7.1 [Event Types](#event-types)
   - 7.2 [Connection State Handling](#connection-state-handling)
   - 7.3 [Full Working Example](#full-working-example)
8. [Advanced Usage](#advanced-usage)
   - 8.1 [Turn Off/On Camera](#turn-offon-camera)
   - 8.2 [Switch Camera](#switch-camera)
   - 8.3 [Mute/Unmute Microphone](#muteunmute-microphone)
9. [Conferencing (Multi-user Rooms)](#conferencing-multi-user-rooms)
10. [Chat Support](#chat-support)

## Installation

Add the Red5 WebRTC SDK framework to your Xcode project.

Add dependencies to your project using Swift Package Manager or CocoaPods:

**Using Swift Package Manager:**
```swift
dependencies: [
    .package(url: "https://github.com/webrtc-sdk/webrtc-ios", from: "142.0.0")
]
```

Example app here:

https://github.com/red5pro/red5pro-ios-testbed

## Configuration Notes

Ensure you have the necessary permissions in your `Info.plist` for publishing:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to stream video</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to stream audio</string>
```

## Requirements

- Red5Pro SDK license key
- Camera and microphone permissions for publishing
- iOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.5 or later

## Quick Start

```swift
import WebRTC
import Red5WebRTCKit

// Create video renderer
let videoRenderer = RTCMTLVideoView()
videoRenderer.contentMode = .scaleAspectFill
videoRenderer.videoContentMode = .scaleAspectFill

// Create configuration
let config = Red5WebrtcClientConfig()
config.streamManagerHost = "userid-xxx-xxx.cloud.red5.net"
config.appName = "live"
config.streamName = "myStream"
config.userName = "username" // If auth enabled
config.password = "password" // If auth enabled
config.videoEnabled = true
config.audioEnabled = true
config.videoWidth = 640
config.videoHeight = 480
config.videoFps = 30
config.videoBitrate = 750
config.videoRenderer = videoRenderer

// Build client
let webrtcClient = Red5WebrtcClientBuilder()
    .setStreamManagerHost(config.streamManagerHost ?? "")
    .setPort(443)
    .setAppName(config.appName)
    .setStreamName(config.streamName ?? "")
    .setVideoEnabled(config.videoEnabled)
    .setAudioEnabled(config.audioEnabled)
    .setVideoWidth(config.videoWidth)
    .setVideoHeight(config.videoHeight)
    .setVideoFps(config.videoFps)
    .setVideoBitrate(config.videoBitrate)
    .setEventListener(self)
    .build()

// Set renderer on client
webrtcClient.setVideoRenderer(videoRenderer)

// Start preview
webrtcClient.startPreview()

// Publish a stream
webrtcClient.publish()

// Subscribe to a stream
webrtcClient.subscribe()
```

## Usage

The SDK supports both publishing to Red5 Cloud (Stream Manager deployments) and standalone Red5Pro servers, as well as subscription (playback) with WebRTC for all streams on both cloud and standalone deployments.

**To publish:** Request camera/microphone permissions, create a `Red5WebrtcClient` using `Red5WebrtcClientBuilder()`, set up a video renderer, start preview, and call `webrtcClient.publish()`.

**To subscribe:** Create a `Red5WebrtcClient` using `Red5WebrtcClientBuilder()`, set up a video renderer, and call `webrtcClient.subscribe()`.

### Publishing to Red5 Cloud and Standalone with WebRTC

#### Step 1: Import the SDK

Import the necessary frameworks in your Swift file:

```swift
import SwiftUI
import AVFoundation
import WebRTC
import Red5WebRTCKit
```

#### Step 2: Request Publish Permissions

These permissions are required for publishing. Request them before starting the stream:

```swift
import AVFoundation

func checkPermissions(completion: @escaping (Bool) -> Void) {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    
    if cameraStatus == .authorized && micStatus == .authorized {
        completion(true)
        return
    }
    
    // Request camera permission
    AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
        guard cameraGranted else {
            completion(false)
            return
        }
        
        // Request microphone permission
        AVCaptureDevice.requestAccess(for: .audio) { micGranted in
            completion(micGranted)
        }
    }
}
```

#### Step 3: Create Red5WebrtcClient object with Red5WebrtcClientBuilder()

Create the WebRTC client when publish permissions are granted. This single object handles all streaming configuration.

**For Red5 Cloud (Stream Manager):**
- Use `setStreamManagerHost()` with your stream manager host address
- Example: `userid-xxx-xxx.cloud.red5.net`

**For Standalone Server:**
- Use `setServerIp()` with your server IP address
- Use `setPort()` if different from default (443)

```swift
// Create configuration
let config = Red5WebrtcClientConfig()
config.streamManagerHost = "userid-xxx-xxx.cloud.red5.net" // For cloud
// config.serverIp = "192.168.1.100" // For standalone
config.port = 443 // Default is 443
config.appName = "live"
config.streamName = "myStreamName"
config.userName = "username" // If username/password auth enabled
config.password = "password" // If username/password auth enabled
config.token = "authToken" // If token auth enabled
config.videoEnabled = true
config.audioEnabled = true
config.videoWidth = 640
config.videoHeight = 480
config.videoFps = 30
config.videoBitrate = 750
config.nodeGroup = "default" // Optional: specify node group for cloud

// Build the client
let webrtcClient = Red5WebrtcClientBuilder()
    .setStreamManagerHost(config.streamManagerHost ?? "")
    .setPort(config.port)
    .setAppName(config.appName)
    .setStreamName(config.streamName ?? "")
    .setUserName(config.userName ?? "")
    .setPassword(config.password ?? "")
    .setToken(config.token ?? "")
    .setVideoEnabled(config.videoEnabled)
    .setAudioEnabled(config.audioEnabled)
    .setVideoWidth(config.videoWidth)
    .setVideoHeight(config.videoHeight)
    .setVideoFps(config.videoFps)
    .setVideoBitrate(config.videoBitrate)
    .setNodeGroup(config.nodeGroup ?? "default")
    .setEventListener(self)
    .build()
```

#### Step 4: Setup Video Renderer

Create and configure the video renderer for displaying the camera preview:

```swift
// Create the video renderer
let videoRenderer = RTCMTLVideoView()
videoRenderer.contentMode = .scaleAspectFill
videoRenderer.videoContentMode = .scaleAspectFill

// Set the renderer on the client
webrtcClient.setVideoRenderer(videoRenderer)
```

**For SwiftUI:**

```swift
struct VideoRendererView: UIViewRepresentable {
    let renderer: RTCMTLVideoView
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        return renderer
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        // No updates needed
    }
}

// Usage in SwiftUI
struct ContentView: View {
    @StateObject private var publishManager = PublishManager()
    
    var body: some View {
        if let renderer = publishManager.localVideoRenderer {
            VideoRendererView(renderer: renderer)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
```

#### Step 5: Start Preview

When `webrtcClient` is created, it performs a license check. Implement `Red5ProWebrtcEventDelegate` in your class and override `onLicenseValidated`:

```swift
extension YourClass: Red5ProWebrtcEventDelegate {
    func onLicenseValidated(validated: Bool, message: String) {
        if validated {
            webrtcClient.startPreview()
            print("License check success")
        } else {
            print("License check failed: \(message)")
        }
    }
}
```

After successful validation, call `webrtcClient.startPreview()` to see the camera preview rendering on the video view.

#### Step 6: Start Publishing

Call `webrtcClient.publish("streamName")` to start publishing:

```swift
webrtcClient.publish("streamName")
```

### Subscribing to Red5 Cloud and Standalone Streams with WebRTC

#### Step 1: Import the SDK

Import the necessary frameworks in your Swift file:

```swift
import SwiftUI
import WebRTC
import Red5WebRTCKit
```

#### Step 2: Create Red5WebrtcClient object with Red5WebrtcClientBuilder()

Configure the client for subscription. Use the same host configuration as publishing:

```swift
// Create configuration
let config = Red5WebrtcClientConfig()
config.streamManagerHost = "userid-755-2ccfa36e4c.cloud.red5.net" // For cloud
// config.serverIp = "192.168.1.100" // For standalone
config.port = 443
config.appName = "live"
config.streamName = "myStreamName"
config.userName = "username" // If auth enabled
config.password = "password" // If auth enabled
config.token = "authToken" // If token auth enabled

// Build the client
let webrtcClient = Red5WebrtcClientBuilder()
    .setStreamManagerHost(config.streamManagerHost ?? "")
    .setPort(config.port)
    .setAppName(config.appName)
    .setStreamName(config.streamName ?? "")
    .setUserName(config.userName ?? "")
    .setPassword(config.password ?? "")
    .setToken(config.token ?? "")
    .setEventListener(self)
    .build()
```

#### Step 3: Setup Video Renderer

Create and configure the video renderer for displaying the remote stream:

```swift
// Create the video renderer
let videoRenderer = RTCMTLVideoView()
videoRenderer.contentMode = .scaleAspectFill
videoRenderer.videoContentMode = .scaleAspectFill

// Set the renderer on the client
webrtcClient.setVideoRenderer(videoRenderer)
```

#### Step 4: Start Subscribing

Call `webrtcClient.subscribe("streamName")` to start subscribing:

```swift
webrtcClient.subscribe("streamName")
```

## Listening For Events

Implement `Red5ProWebrtcEventDelegate` in your class to handle SDK events.

### Event Types

The SDK emits the following events:

```swift
func onPublishStarted()
func onPublishStopped()
func onPublishFailed(error: String)
func onSubscribeStarted()
func onSubscribeStopped()
func onSubscribeFailed(error: String)
func onIceConnectionStateChanged(state: IceConnectionState)
func onConnectionStateChanged(state: PeerConnectionState)
func onError(error: String)
func onPreviewStarted()
func onPreviewStopped()
func onLicenseValidated(validated: Bool, message: String)
func onChatMessageReceived(channel: String, message: JSONCodable)
func onChatConnected()
func onChatDisconnected()
func onChatSendError(channel: String, errorMessage: String)
func onChatSendSuccess(channel: String, timetoken: NSNumber)
```

### Conference Delegate

Implement `ConferenceDelegate` for room events:

```swift
func onJoinRoomSuccess(roomId: String, participants: [Red5ConferenceParticipant])
func onJoinRoomFailed(statusCode: Int, message: String)
func onParticipantJoined(uid: String, role: String, metaData: String, videoEnabled: Bool, audioEnabled: Bool, renderer: RTCVideoRenderer?)
func onParticipantLeft(uid: String)
func onParticipantMediaUpdate(uid: String, videoEnabled: Bool, audioEnabled: Bool, timestamp: Int64)
func onParticipantRendererUpdate(uid: String, renderer: RTCVideoRenderer)
```

### Connection State Handling

Handle connection state changes using `IceConnectionState`:

```swift
extension YourClass: Red5ProWebrtcEventDelegate {
    func onIceConnectionStateChanged(state: IceConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Connected to server")
            case .disconnected, .failed:
                print("Connection lost")
            default:
                break
            }
        }
    }
}
```

### Full Working Example

```swift
import SwiftUI
import AVFoundation
import WebRTC
import Red5WebRTCKit

class PublishManager: NSObject, ObservableObject {
    private var webrtcClient: Red5WebrtcClient?
    @Published var localVideoRenderer: RTCMTLVideoView?
    @Published var isReady: Bool = false
    
    func setup() {
        // Create renderer
        self.localVideoRenderer = RTCMTLVideoView()
        self.localVideoRenderer?.contentMode = .scaleAspectFill
        self.localVideoRenderer?.videoContentMode = .scaleAspectFill
        
        // Configure client
        let config = Red5WebrtcClientConfig()
        config.streamManagerHost = "userid-xxx-xxx.cloud.red5.net"
        config.port = 443
        config.appName = "live"
        config.streamName = "myStream"
        config.videoEnabled = true
        config.audioEnabled = true
        config.videoWidth = 640
        config.videoHeight = 480
        config.videoFps = 30
        config.videoBitrate = 750
        config.videoRenderer = self.localVideoRenderer
        
        // Build client
        webrtcClient = Red5WebrtcClientBuilder()
            .setStreamManagerHost(config.streamManagerHost ?? "")
            .setPort(config.port)
            .setAppName(config.appName)
            .setStreamName(config.streamName ?? "")
            .setVideoEnabled(config.videoEnabled)
            .setAudioEnabled(config.audioEnabled)
            .setVideoWidth(config.videoWidth)
            .setVideoHeight(config.videoHeight)
            .setVideoFps(config.videoFps)
            .setVideoBitrate(config.videoBitrate)
            .setEventListener(self)
            .build()
        
        // Set renderer
        webrtcClient?.setVideoRenderer(self.localVideoRenderer!)
    }
    
    func startPreview() {
        webrtcClient?.startPreview()
    }
    
    func startPublish() {
        webrtcClient?.publish()
    }
    
    func stopPublish() {
        webrtcClient?.stopPublish()
    }
    
    func stopPreview() {
        webrtcClient?.stopPreview()
    }
    
    func release() {
        webrtcClient?.stopPublish()
        webrtcClient?.stopPreview()
        webrtcClient = nil
        localVideoRenderer = nil
    }
}

// MARK: - Red5ProWebrtcEventDelegate

extension PublishManager: Red5ProWebrtcEventDelegate {
    func onPublishStarted() {
        DispatchQueue.main.async {
            print("Publish started")
        }
    }
    
    func onPublishStopped() {
        DispatchQueue.main.async {
            print("Publish stopped")
        }
    }
    
    func onPublishFailed(error: String) {
        DispatchQueue.main.async {
            print("Publish failed: \(error)")
        }
    }
    
    func onSubscribeStarted() {
        DispatchQueue.main.async {
            print("Subscribe started")
        }
    }
    
    func onSubscribeStopped() {
        DispatchQueue.main.async {
            print("Subscribe stopped")
        }
    }
    
    func onSubscribeFailed(error: String) {
        DispatchQueue.main.async {
            print("Subscribe error: \(error)")
        }
    }
    
    func onIceConnectionStateChanged(state: IceConnectionState) {
        DispatchQueue.main.async {
            print("ICE connection state: \(state)")
        }
    }
    
    func onConnectionStateChanged(state: PeerConnectionState) {
        DispatchQueue.main.async {
            print("Connection state: \(state)")
        }
    }
    
    func onError(error: String) {
        DispatchQueue.main.async {
            print("Error: \(error)")
        }
    }
    
    func onPreviewStarted() {
        DispatchQueue.main.async {
            print("Preview started")
            self.isReady = true
        }
    }
    
    func onPreviewStopped() {
        DispatchQueue.main.async {
            print("⏹️ Preview stopped")
        }
    }
    
    func onLicenseValidated(validated: Bool, message: String) {
        DispatchQueue.main.async {
            if validated {
                self.webrtcClient?.startPreview()
            } else {
                print("License invalid: \(message)")
            }
        }
    }
}
```

## Advanced Usage

### Turn Off/On Camera

Toggle camera on/off during streaming:

```swift
private var isCameraEnabled = true

func toggleCamera() {
    isCameraEnabled.toggle()
    webrtcClient.setVideoEnabled(isCameraEnabled)
}
```

### Switch Camera

Switch between front and back cameras:

```swift
func switchCamera() {
    webrtcClient.switchCamera()
}
```

### Mute/Unmute Microphone

Toggle microphone on/off during streaming:

```swift
private var isMicEnabled = true

func toggleMic() {
    isMicEnabled.toggle()
    webrtcClient.setAudioEnabled(isMicEnabled)
}
```

## Conferencing (Multi-user Rooms)

Join multi-user conference rooms to publish and subscribe to multiple participants.

### Step 1: Join a Room

```swift
let roomId = "myConferenceRoom"
let userId = "user123"
let role = "publisher" // or "subscriber"
let metadata = "{\"displayName\": \"John Doe\"}"

webrtcClient.join(roomId: roomId, streamName: userId, role: role, metadata: metadata)
```

### Step 2: Handle Room Events

Implement `ConferenceDelegate` to be notified when participants join or leave:

```swift
extension YourManager: ConferenceDelegate {
    func onJoinRoomSuccess(roomId: String, participants: [Red5ConferenceParticipant]) {
        print("Joined room: \(roomId)")
    }
    
    func onParticipantJoined(uid: String, role: String, metaData: String, videoEnabled: Bool, audioEnabled: Bool, renderer: RTCVideoRenderer?) {
        print("Participant joined: \(uid)")
        // Attach renderer if available
    }
}
```

### Step 3: Leave Room

```swift
webrtcClient.leave()
```

## Chat Support

The SDK includes built-in chat support via PubNub.

### Step 1: Configure Chat

Import PubNub and Red5 SDK and Client:

```swift
import PubNubSDK
import Red5WebRTCKit
import Red5PubNubClient
```

Use `Red5WebrtcClientConfig` to set your PubNub keys:

```swift
let config = Red5WebrtcClientConfig()
    config.pubnubPublishKey = SettingsManager.getPubnubPubKey()
    config.pubnubSubscribeKey = SettingsManager.getPubnubSubKey()
    config.licenseKey = SettingsManager.getSdkLicenseKey()
    // ... other config
    .build()
```

### Step 2: Join and Send Messages

```swift
let pubNubClient = Red5PubNubClient(config: config, webrtcClientListener: ChatEventListener(chatView: self))
// Subscribe to a channel
pubNubClient.subscribeChannel(channelName: "main-chat")
// Send a text message
pubNubClient.sendTextMessage(channelName: "main-chat", message: "Hello World!", metaData: nil)
```

### Step 3: Receive Messages

Implement `onChatMessageReceived` in your `Red5ProWebrtcEventDelegate`:

```swift
func onChatMessageReceived(channel: String, message: JSONCodable) {
    print("Received message in \(channel): \(message)")
}
```
