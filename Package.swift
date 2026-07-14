// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "AITextView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AITextView",
            targets: ["AITextView"]
        ),
        .library(
            name: "AIStreamingMarkdown",
            targets: ["AIStreamingMarkdown"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-markdown.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "AITextView",
            dependencies: [],
            path: "AITextView/Sources",
            resources: [.process("Resources")]
        ),
        .target(
            name: "AIStreamingMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "AIStreamingMarkdown/Sources"
        ),
        .testTarget(
            name: "AIStreamingMarkdownTests",
            dependencies: ["AIStreamingMarkdown"],
            path: "AIStreamingMarkdown/Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
