// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "libtesseract",
    products: [
        .library(
            name: "libtesseract",
            type: .static,
            targets: ["libtesseract"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "libtesseract",
            path: "./build/libtesseract.xcframework")
    ]
)

