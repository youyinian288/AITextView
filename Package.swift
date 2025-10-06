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
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AITextView",
            dependencies: [],
            path: "RichEditorView/Sources",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AITextViewTests",
            dependencies: ["AITextView"],
            path: "RichEditorViewTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
