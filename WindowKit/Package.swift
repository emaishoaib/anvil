// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WindowKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "WindowKit", targets: ["WindowKit"]),
    ],
    targets: [
        .target(name: "WindowKit"),
        .testTarget(name: "WindowKitTests", dependencies: ["WindowKit"]),
    ]
)
