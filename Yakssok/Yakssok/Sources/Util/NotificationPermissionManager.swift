//
//  NotificationPermissionManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/15/25.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()

    private var isShowingAlert = false
    private var permissionCheckTimer: Timer?
    private let checkInterval: TimeInterval = 30.0

    var onPermissionChanged: ((Bool) -> Void)?

    private init() {}

    /// 홈에서 호출 - 앱 진입 시 권한 체크
    @MainActor
    func checkAndHandlePermissionOnAppEntry() async {
        await checkPermissionAndHandle()
    }

    /// 앱이 포그라운드로 올 때 호출
    @MainActor
    func handleAppWillEnterForeground() async {
        await checkPermissionAndHandle()
    }

    /// 앱이 백그라운드로 갈 때 호출
    func handleAppDidEnterBackground() {
        isShowingAlert = false
    }

    /// 현재 권한 상태 확인
    func checkPermissionStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return [UNAuthorizationStatus.authorized, .provisional, .ephemeral]
            .contains(settings.authorizationStatus)
    }

    /// 핵심 로직 - 권한 체크하고 처리
    @MainActor
    private func checkPermissionAndHandle() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let hasPermission = [UNAuthorizationStatus.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus)

        // 권한 상태 알림
        notifyPermissionChanged(granted: hasPermission)

        if hasPermission {
            // 시스템 권한 있음
            UIApplication.shared.registerForRemoteNotifications()

            let userWantsNotification = getUserWantsNotification()
            if userWantsNotification {
                // 토글 ON → 정상 동작
                stopPeriodicPermissionCheck()
            } else {
                // 토글 OFF → 무한 요청 시작
                await showCriticalPermissionAlert()
                startPeriodicPermissionCheck()
            }
        } else {
            // 시스템 권한 없음 → 무한 요청 시작
            switch settings.authorizationStatus {
            case .notDetermined:
                // 아직 물어보지 않음 → 바로 요청
                await requestPermissionDirectly()
            case .denied:
                // 거부됨 → 무한 요청
                await showCriticalPermissionAlert()
                startPeriodicPermissionCheck()
            default:
                await showCriticalPermissionAlert()
                startPeriodicPermissionCheck()
            }
        }
    }

    /// 사용자가 알림을 원하는지 확인
    private func getUserWantsNotification() -> Bool {
        let hasToggleSetting = UserDefaults.standard.object(forKey: "userNotificationToggle") != nil
        return hasToggleSetting ? UserDefaults.standard.bool(forKey: "userNotificationToggle") : true
    }

    /// 시스템 권한 요청
    @MainActor
    private func requestPermissionDirectly() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            if granted {
                UIApplication.shared.registerForRemoteNotifications()
                // 권한 허용되면 토글 ON
                UserDefaults.standard.set(true, forKey: "userNotificationToggle")
                stopPeriodicPermissionCheck()
                notifyPermissionChanged(granted: true)
            } else {
                await showCriticalPermissionAlert()
                startPeriodicPermissionCheck()
                notifyPermissionChanged(granted: false)
            }
        } catch {
            await showCriticalPermissionAlert()
            notifyPermissionChanged(granted: false)
        }
    }

    /// 권한 요청 알림창 표시
    @MainActor
    private func showCriticalPermissionAlert() async {
        guard !isShowingAlert else { return }
        isShowingAlert = true

        return await withCheckedContinuation { continuation in
            let alert = UIAlertController(
                title: "알림 권한 요청",
                message: "약 알람과 잔소리•칭찬 수신을 위해 알림 권한이 필요합니다.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "설정에서 알림 켜기", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                self.isShowingAlert = false
                continuation.resume()
            })

            alert.addAction(UIAlertAction(title: "나중에", style: .cancel) { _ in
                self.isShowingAlert = false
                continuation.resume()
            })

            presentAlert(alert)
        }
    }

    /// 주기적 권한 체크 시작
    private func startPeriodicPermissionCheck() {
        stopPeriodicPermissionCheck()

        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkPermissionAndHandle()
            }
        }
    }

    /// 주기적 권한 체크 중단
    private func stopPeriodicPermissionCheck() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }

    /// 권한 변경 알림
    private func notifyPermissionChanged(granted: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.onPermissionChanged?(granted)
        }
    }

    /// 알림창 표시 헬퍼
    @MainActor
    private func presentAlert(_ alert: UIAlertController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        topViewController.present(alert, animated: true)
    }

    deinit {
        stopPeriodicPermissionCheck()
    }
}
