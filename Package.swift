// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ARCraft",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "ARCraft", targets: ["ARCraft"])
    ],
    targets: [
        .target(
            name: "ARCraft",
            path: "Sources/ARCraft"
        ),
        .testTarget(
            name: "ARCraftTests",
            dependencies: ["ARCraft"]
        )
    ]
)
