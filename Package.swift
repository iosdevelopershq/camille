// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Camille",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Camille", targets: ["Camille"]),
        .library(name: "CamilleServices", targets: ["CamilleServices"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChameleonBot/Chameleon.git", .branch("revamp")),
    ],
    targets: [
        .target(name: "Camille", dependencies: ["CamilleServices", .product(name: "VaporProviders", package: "Chameleon")]),
        .target(name: "CamilleServices", dependencies: [.product(name: "ChameleonKit", package: "Chameleon")]),
    ]
)
