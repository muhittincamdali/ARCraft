// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCraft",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ARCraft",
            targets: ["ARCraft"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ARCraft",
            dependencies: [],
            path: "Sources/ARCraft",
            swiftSettings: [
                .define("ARCRAFT_VISIONOS", .when(platforms: [.visionOS])),
                .define("ARCRAFT_IOS", .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "ARCraftTests",
            dependencies: ["ARCraft"],
            path: "Tests/ARCraftTests"
        )
    ]
)
