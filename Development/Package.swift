import PackageDescription

let package = Package(
    name: "Camille",
    targets: [
        Target(
            name: "Camille",
            dependencies: [
                .Target(name: "Bot"),
                .Target(name: "Sugar")
            ]
        ),
        Target(
            name: "Sugar",
            dependencies: [
                .Target(name: "Bot")
            ]
        ),
        Target(
            name: "Bot",
            dependencies: [
                .Target(name: "Common"),
                .Target(name: "Config"),
                .Target(name: "Models"),
                .Target(name: "Services"),
                .Target(name: "WebAPI"),
                .Target(name: "RTMAPI"),
                ]
        ),
        Target(
            name: "Common",
            dependencies: []
        ),
        Target(
            name: "Config",
            dependencies: [
                .Target(name: "Common")
            ]
        ),
        Target(
            name: "Models",
            dependencies: [
                .Target(name: "Common")
            ]
        ),
        Target(
            name: "Services",
            dependencies: [
                .Target(name: "Common")
            ]
        ),
        Target(
            name: "WebAPI",
            dependencies: [
                .Target(name: "Common"),
                .Target(name: "Services"),
                .Target(name: "Models")
            ]
        ),
        Target(
            name: "RTMAPI",
            dependencies: [
                .Target(name: "Common"),
                .Target(name: "Services"),
                .Target(name: "Models")
            ]
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 0, minor: 18),
        .Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 5),
        ],
    exclude: [
        "XcodeProject"
    ]
)
