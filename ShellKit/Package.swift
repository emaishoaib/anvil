// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ShellKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "ShellKit", targets: ["ShellKit"]),
    ],
    targets: [
        .target(name: "ShellKit"),
        .testTarget(name: "ShellKitTests", dependencies: ["ShellKit"]),
    ]
)
