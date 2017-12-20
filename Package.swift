// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Camille",
    products: [
        .executable(name: "Camille", targets: ["Camille"]),
        .library(name: "CamilleServices", targets: ["CamilleServices"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChameleonBot/Chameleon.git", .upToNextMinor(from: "0.0.0")),
    ],
    targets: [
        .target(name: "Camille", dependencies: ["CamilleServices"]),
        .target(name: "CamilleServices", dependencies: ["Chameleon"]),
        .testTarget(name: "CamilleTests", dependencies: ["CamilleServices"]),
    ]
)
