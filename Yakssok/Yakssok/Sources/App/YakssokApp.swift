import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            guard TokenManager.shared.isLoggedIn else {
                return
            }

            try? await FCMClient.liveValue.sendTokenToServer()
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // error
    }

    // 포그라운드 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let content = notification.request.content

        let userToggleOn = UserDefaults.standard.bool(forKey: "userNotificationToggle")
        let hasToggleSetting = UserDefaults.standard.object(forKey: "userNotificationToggle") != nil
        let shouldShowNotification = hasToggleSetting ? userToggleOn : true

        if !shouldShowNotification {
            return []
        }

        // data-only 메시지 감지
        if isDataOnlyMessage(content.userInfo) {
            await handleDataOnlyMessage(content.userInfo)
            return []
        } else {
            if content.sound == nil {
                let newContent = content.mutableCopy() as! UNMutableNotificationContent
                newContent.sound = .default
                let newRequest = UNNotificationRequest(
                    identifier: "sound-fixed-\(Date().timeIntervalSince1970)",
                    content: newContent,
                    trigger: nil
                )
                try? await UNUserNotificationCenter.current().add(newRequest)
                return [.banner]
            } else {
                return [.banner, .sound]
            }
        }
    }

    // 알림 탭
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userToggleOn = UserDefaults.standard.bool(forKey: "userNotificationToggle")
        if userToggleOn {
            await handleNotificationTap(response)
        }
    }

    // 백그라운드 수신
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if isDataOnlyMessage(userInfo) {
            Task {
                await handleDataOnlyMessage(userInfo)
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    // data-only 메시지 감지 로직
    private func isDataOnlyMessage(_ userInfo: [AnyHashable: Any]) -> Bool {
        // content-available = 1이고 title, body, soundType이 최상위에 있으면 data-only
        if let aps = userInfo["aps"] as? [String: Any],
           let contentAvailable = aps["content-available"] as? Int,
           contentAvailable == 1,
           userInfo["title"] != nil,
           userInfo["soundType"] != nil {
            return true
        }

        // 기존 방식도 지원 (data 키 내부에 있는 경우)
        return userInfo["data"] as? [String: Any] != nil
    }

    // data-only 메시지 처리 로직
    private func handleDataOnlyMessage(_ userInfo: [AnyHashable: Any]) async {
        var title: String
        var body: String
        var soundTypeString: String

        if let directTitle = userInfo["title"] as? String,
           let directBody = userInfo["body"] as? String,
           let directSoundType = userInfo["soundType"] as? String {
            title = directTitle
            body = directBody
            soundTypeString = directSoundType
        }

        else if let data = userInfo["data"] as? [String: Any],
                let dataTitle = data["title"] as? String,
                let dataBody = data["body"] as? String,
                let dataSoundType = data["soundType"] as? String {
            title = dataTitle
            body = dataBody
            soundTypeString = dataSoundType
        }
        else {
            return
        }

        guard let soundType = FCMSoundType(rawValue: soundTypeString) else {
            return
        }

        await createCustomNotification(title: title, body: body, soundType: soundType)
    }

    private func createCustomNotification(title: String, body: String, soundType: FCMSoundType) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if soundType.isAvailable {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundType.fileName))
        } else {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: "custom-data-only-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // error
        }
    }

    private func handleNotificationTap(_ response: UNNotificationResponse) async {
        // Handle notification tap
    }
}

// MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken, !fcmToken.isEmpty else {
            return
        }

        Task {
            guard TokenManager.shared.isLoggedIn else {
                return
            }
            try? await FCMManager.shared.sendTokenToServer()
        }
    }
}

@main
struct YakssokApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var isInitialized = false

    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        FirebaseApp.configure()
        setupKakaoSDK()
        initializeNotificationSettings()
    }

    private func initializeNotificationSettings() {
        if UserDefaults.standard.object(forKey: "userNotificationToggle") == nil {
            UserDefaults.standard.set(true, forKey: "userNotificationToggle")
        }
    }

    private func setupKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("카카오 앱 키 누락")
        }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }

    private func performAsyncInitialization() {
        guard !isInitialized else { return }
        isInitialized = true
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
            await setupPushNotifications()
        }
    }

    @MainActor
    private func setupPushNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            // notDetermined일 때는 HomeFeature에서 처리
            break
        case .authorized, .provisional, .ephemeral:
            UIApplication.shared.registerForRemoteNotifications()
        default: break
        }
        await FCMClient.liveValue.setupFCM()
    }

    @MainActor
    private func requestNotificationPermission() async {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        if granted == true {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onAppear { performAsyncInitialization() }
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        UIApplication.shared.applicationIconBadgeNumber = 0

                        // 앱이 포그라운드로 올 때 권한 체크
                        Task {
                            let isGranted = await NotificationPermissionManager.shared.checkPermissionStatus()
                            NotificationPermissionManager.shared.onPermissionChanged?(isGranted)
                        }

                    case .background:
                        NotificationPermissionManager.shared.handleAppDidEnterBackground()

                    default:
                        break
                    }
                }
        }
    }
}
