// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "RulesKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "RulesKit", targets: ["RulesKit"]),
    ],
    targets: [
        .target(name: "RulesKit"),
        .testTarget(name: "RulesKitTests", dependencies: ["RulesKit"]),
    ]
)
