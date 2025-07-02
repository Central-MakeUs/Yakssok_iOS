import ProjectDescription

let project = Project(
    name: "Yakssok",
    targets: [
        .target(
            name: "Yakssok",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Yakssok",
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
            dependencies: []
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
