// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LauncherKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "LauncherKit", targets: ["LauncherKit"]),
    ],
    targets: [
        .target(name: "LauncherKit"),
        .testTarget(name: "LauncherKitTests", dependencies: ["LauncherKit"]),
    ]
)
