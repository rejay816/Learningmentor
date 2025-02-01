// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LearningMentor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "LearningMentor",
            targets: ["LearningMentorApp"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "App",
            targets: ["App"]
        ),
        .library(
            name: "Features",
            targets: ["Features"]
        ),
        .library(
            name: "UI",
            targets: ["UI"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "LearningMentorApp",
            dependencies: [
                "Core",
                "App",
                "Features",
                "UI"
            ],
            path: "Sources/LearningMentorApp"
        ),
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"
        ),
        .target(
            name: "UI",
            dependencies: ["Core"],
            path: "Sources/UI"
        ),
        .target(
            name: "App",
            dependencies: [
                "Core",
                "Features",
                "UI"
            ],
            path: "Sources/App",
            resources: [
                .copy("Resources/Assets")
            ]
        ),
        .target(
            name: "Features",
            dependencies: [
                "Core",
                "UI"
            ],
            path: "Sources/Features",
            resources: [
                .process("Language/Storage/LanguageLearning.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "LearningMentorTests",
            dependencies: [
                "Core",
                "App",
                "Features",
                "UI"
            ],
            path: "Tests/LearningMentorTests"
        )
    ]
) 