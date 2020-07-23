// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MPushSwift",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "MPushSwift",
            targets: ["MPush"])

    ],
    dependencies: [
        .package(url: "https://github.com/Mumble-SRL/MBNetworkingSwift.git", from: "1.0.17")
    ],
    targets: [
        .target(
            name: "MPush",
            dependencies: ["MBNetworkingSwift"],
            path: "MPush"
        )
    ]
)
