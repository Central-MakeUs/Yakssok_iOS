import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct YakssokApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("카카오 앱 키를 Info.plist에서 찾을 수 없습니다.")
        }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL(perform: { url in
                    // 카카오 로그인 URL 스키마 처리
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
