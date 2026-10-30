// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Monetization",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Monetization", targets: ["Monetization"]),
    ],
    dependencies: [
        .package(path: "../Core"),
    ],
    targets: [
        .target(name: "Monetization", dependencies: ["Core"]),
        .testTarget(name: "MonetizationTests", dependencies: ["Monetization"]),
    ],
)
