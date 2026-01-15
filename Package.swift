// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KnowledgeManagementAppSwift",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "KnowledgeManagementCore", targets: ["KnowledgeManagementCore"]),
        .executable(name: "kmapp", targets: ["kmapp"])
    ],
    targets: [
        .target(
            name: "KnowledgeManagementCore",
            path: "Sources/KnowledgeManagementCore"
        ),
        .executableTarget(
            name: "kmapp",
            dependencies: ["KnowledgeManagementCore"],
            path: "Sources/kmapp"
        ),
        .testTarget(
            name: "KnowledgeManagementCoreTests",
            dependencies: ["KnowledgeManagementCore"],
            path: "Tests/KnowledgeManagementCoreTests"
        )
    ]
)
