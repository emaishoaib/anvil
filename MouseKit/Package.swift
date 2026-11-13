// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MouseKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "MouseKit", targets: ["MouseKit"]),
    ],
    targets: [
        .target(name: "MouseKit"),
        .testTarget(name: "MouseKitTests", dependencies: ["MouseKit"]),
    ]
)
