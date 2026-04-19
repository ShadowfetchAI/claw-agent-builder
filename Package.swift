// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ClawAgentBuilder",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "ClawAgentBuilder",
            targets: ["ClawAgentBuilder"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ClawAgentBuilder",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "ClawAgentBuilderTests",
            dependencies: ["ClawAgentBuilder"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
