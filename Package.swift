// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Camille",
    dependencies: [
        .Package(url: "https://github.com/ChameleonBot/Chameleon.git", majorVersion: 1),
    ],
    exclude: [
        "XcodeProject"
    ]
)
