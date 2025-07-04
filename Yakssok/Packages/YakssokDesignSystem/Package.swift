// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YakssokDesignSystem",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "YakssokDesignSystem",
            targets: ["YakssokDesignSystem"]
        )
    ],
    targets: [
        .target(
            name: "YakssokDesignSystem",
            dependencies: []
        )
    ]
)
