// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureHome",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "FeatureHome", targets: ["FeatureHome"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(name: "FeatureHome", dependencies: ["Core", "DesignSystem"]),
        .testTarget(name: "FeatureHomeTests", dependencies: ["FeatureHome"]),
    ],
)
