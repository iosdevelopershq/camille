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
        .package(url: "https://github.com/mxcl/LegibleError.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Camille", dependencies: [
            "CamilleServices",
            .product(name: "VaporProviders", package: "Chameleon"),
            .product(name: "LegibleError", package: "LegibleError"),
        ]),
        .target(name: "CamilleServices", dependencies: [.product(name: "ChameleonKit", package: "Chameleon")]),
        .testTarget(name: "CamilleTests", dependencies: [
            "CamilleServices",
            .product(name: "ChameleonTestKit", package: "Chameleon")
        ]),
    ]
)
