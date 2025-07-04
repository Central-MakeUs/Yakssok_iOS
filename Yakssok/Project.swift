import ProjectDescription

let project = Project(
    name: "Yakssok",
    targets: [
        .target(
            name: "Yakssok",
            destinations: .iOS,
            product: .app,
            bundleId: "com.yakssok.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Yakssok/Sources/**"],
            resources: ["Yakssok/Resources/**"],
            dependencies: [.external(name: "ComposableArchitecture"),
                           .external(name: "Dependencies"),
                           .external(name: "YakssokDesignSystem")]
        ),
        .target(
            name: "YakssokTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.YakssokTests",
            infoPlist: .default,
            sources: ["Yakssok/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Yakssok")]
        ),
    ]
)
