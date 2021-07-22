// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpeechRecognizer",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "speechrecognizer", targets: ["SpeechRecognizer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "SpeechRecognizer",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "SpeechRecognizerTests",
            dependencies: ["SpeechRecognizer"]),
    ]
)
