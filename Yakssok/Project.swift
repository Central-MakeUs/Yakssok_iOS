import ProjectDescription

let project = Project(
    name: "Yakssok",
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Config.xcconfig"),
            .release(name: "Release", xcconfig: "Config.xcconfig")
        ]
    ),
    targets: [
        .target(
            name: "Yakssok",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.yakssok.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIAppFonts": [
                        "Pretendard-Regular.otf",
                        "Pretendard-Medium.otf",
                        "Pretendard-SemiBold.otf",
                        "Pretendard-Bold.otf"
                    ],
                    "CFBundleDisplayName": "약쏙",
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "9",
                    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
                    "API_BASE_URL": "https://yakssok.site",
                    "MASTER_ACCESS_TOKEN": "$(MASTER_ACCESS_TOKEN)",
                    "MASTER_REFRESH_TOKEN": "$(MASTER_REFRESH_TOKEN)",
                    "MASTER_PASSWORD": "$(MASTER_PASSWORD)",
                    "FirebaseAppDelegateProxyEnabled": false,
                    "UIBackgroundModes": [
                        "remote-notification"
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "kakao",
                            "CFBundleURLSchemes": ["kakao$(KAKAO_NATIVE_APP_KEY)"]
                        ],
                        [
                            "CFBundleURLName": "apple",
                            "CFBundleURLSchemes": ["$(PRODUCT_BUNDLE_IDENTIFIER)"]
                        ]
                    ],
                    "LSApplicationQueriesSchemes": [
                        "kakaokompassauth",
                        "kakaolink"
                    ]
                ]
            ),
            sources: ["Yakssok/Sources/**"],
            resources: ["Yakssok/Resources/**"],
            entitlements: "Yakssok/Yakssok.entitlements",
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "Dependencies"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseMessaging"),
                .external(name: "YakssokDesignSystem")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "VT34K852T5",
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES"
                ]
            )
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
