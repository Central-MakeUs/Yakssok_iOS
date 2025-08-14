// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Yakssok",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/kakao/kakao-ios-sdk",
            from: "2.24.5"
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "12.1.0"
        ),
        .package(path: "../Packages/YakssokDesignSystem")
    ]
)
