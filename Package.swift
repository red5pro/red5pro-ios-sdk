// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Red5WebRTCKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Red5WebRTCKit",
            targets: ["Red5WebRTCKitWrapper"]
        ),
        .library(
            name: "Red5PubNubClient",
            targets: ["Red5PubNubClient"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/stasel/WebRTC.git",
            from: "140.0.0"
        ),
        .package(
            url: "https://github.com/pubnub/swift.git",
            from: "10.0.1"
        )
    ],
    targets: [
        // The pre-built XCFramework containing Red5WebRTCKit
        .binaryTarget(
            name: "Red5WebRTCKitFramework",
            path: "Red5WebRTCKit.xcframework"
        ),
        // Wrapper target that links the framework with its dependencies
        .target(
            name: "Red5WebRTCKitWrapper",
            dependencies: [
                "Red5WebRTCKitFramework",
                .product(name: "WebRTC", package: "WebRTC")
            ],
            path: "Sources/Red5WebRTCKitWrapper",
            linkerSettings: [
                .linkedFramework("WebRTC"),
                .linkedLibrary("swiftCore"),
                .linkedLibrary("swiftFoundation")
            ]
        ),
        .target(
            name: "Red5PubNubClient",
            dependencies: [
                "Red5WebRTCKitFramework",
                .product(name: "PubNubSDK", package: "swift")
            ],
            path: "Red5PubNubClient/Sources"
        )
    ]
)
