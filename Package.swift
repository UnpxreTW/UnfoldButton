// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnfoldButton",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "UnfoldButton", targets: ["UnfoldButton"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "UnfoldButton", dependencies: []),
        .testTarget(name: "UnfoldButtonTests", dependencies: ["UnfoldButton"]),
    ]
)
