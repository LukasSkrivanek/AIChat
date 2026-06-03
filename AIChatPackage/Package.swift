// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AIChatPackage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AIChatCommon", targets: ["AIChatCommon"]),
        .library(name: "AIChatApi", targets: ["AIChatApi"]),
        .library(name: "AIChatDomain", targets: ["AIChatDomain"]),
        .library(name: "AIChatFeatures", targets: ["AIChatFeatures"]),
        .library(name: "AIChatAppFeature", targets: ["AIChatAppFeature"]),
    ],
    targets: [
        .target(name: "AIChatCommon"),
        .target(
            name: "AIChatApi",
            dependencies: [
                "AIChatCommon",
            ]
        ),
        .target(
            name: "AIChatDomain",
            dependencies: [
                "AIChatApi",
                "AIChatCommon",
            ]
        ),
        .target(
            name: "AIChatFeatures",
            dependencies: [
                "AIChatDomain",
                "AIChatCommon",
            ]
        ),
        .target(
            name: "AIChatAppFeature",
            dependencies: [
                "AIChatFeatures",
                "AIChatDomain",
                "AIChatCommon",
            ]
        ),
        .testTarget(
            name: "AIChatDomainTests",
            dependencies: ["AIChatDomain"]
        ),
        .testTarget(
            name: "AIChatFeaturesTests",
            dependencies: ["AIChatFeatures"]
        ),
    ]
)
