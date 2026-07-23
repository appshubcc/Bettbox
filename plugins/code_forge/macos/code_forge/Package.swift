// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "code_forge",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "code-forge", targets: ["code_forge"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "code_forge",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/code_forge",
            publicHeadersPath: "include"
        )
    ]
)
