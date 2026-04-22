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
            url: "https://github.com/red5pro/red5pro-ios-sdk/releases/download/2.1.0.2/Red5WebRTCKit-2.1.0.2-release.b10.red5cloud.xcframework.zip",
            checksum: "c38e9588effafc78be0a3541889105a986bec013c330168f2c0b648e74d45c27"
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
