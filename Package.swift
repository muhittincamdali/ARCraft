// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ARCraft",
    platforms: [
        .iOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "ARCraft", targets: ["ARCraft"]),
    ],
    targets: [
        .target(
            name: "ARCraft",
            path: "Sources/ARCraft",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCraftTests",
            dependencies: ["ARCraft"]
        )
    ]
)
