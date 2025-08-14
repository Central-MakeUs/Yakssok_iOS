import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TokenManager.shared.migrateKeychainIfNeeded()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        Task {
            guard TokenManager.shared.isLoggedIn else {
                return
            }

            try? await FCMClient.liveValue.sendTokenToServer()
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let data = userInfo["data"] as? [String: Any] {
            Task {
                await handleBackgroundDataMessage(data)
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    private func handleBackgroundDataMessage(_ data: [String: Any]) async {
        guard let title = data["title"] as? String,
              let body = data["body"] as? String,
              let soundTypeString = data["soundType"] as? String,
              let soundType = FCMSoundType(rawValue: soundTypeString) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(soundType.fileName + ".mp3"))
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}

@main
struct YakssokApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        FirebaseApp.configure()
        setupPushNotifications()
        setupKakaoSDK()
    }

    private func setupPushNotifications() {
        Task { @MainActor in
            await FCMClient.liveValue.setupFCM()
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    private func setupKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("카카오 앱 키를 Info.plist에서 찾을 수 없습니다.")
        }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
