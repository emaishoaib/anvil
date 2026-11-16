// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ClaudeKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "ClaudeKit", targets: ["ClaudeKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown", from: "0.9.0"),
    ],
    targets: [
        .target(name: "ClaudeKit", dependencies: [.product(name: "Markdown", package: "swift-markdown")]),
        .testTarget(name: "ClaudeKitTests", dependencies: ["ClaudeKit"]),
    ]
)
