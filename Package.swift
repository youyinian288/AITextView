// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "AITextView",
    platforms: [
        .iOS(.v14)
    ],
    products: [
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
            name: "AIStreamingMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "AIStreamingMarkdown/Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
