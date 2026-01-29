// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Red5WebRTCKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Red5WebRTCKit",
            targets: ["Red5WebRTCKit"]
        ),
        .library(
            name: "Red5PubNubClient",
            targets: ["Red5PubNubClient"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/stasel/WebRTC.git", from: "140.0.0"),
        .package(url: "https://github.com/pubnub/swift.git", from: "10.0.1")
    ],
    targets: [
        .binaryTarget(
            name: "Red5WebRTCKit",
            url: "https://github.com/red5pro/red5pro-ios-sdk/releases/download/1.0.0/Red5WebRTCKit-1.0.0-release.b7.red5cloud.xcframework.zip",
            checksum: "aa0a8df4f0011872ba9900ef51ed47b10c8b5080b6736d83aaf81a1a0f39f973"
        ),
        .target(
            name: "Red5PubNubClient",
            dependencies: [
                "Red5WebRTCKit",
                .product(name: "PubNubSDK", package: "swift")
            ],
            path: "Sources/Red5PubNubClient"
        )
    ]
)
