// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Camille",
    targets: [
        Target(name: "CamilleServices"),
        Target(name: "Camille", dependencies: ["CamilleServices"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/ChameleonBot/Chameleon.git", majorVersion: 1),
    ],
    exclude: [
        "XcodeProject"
    ]
)
