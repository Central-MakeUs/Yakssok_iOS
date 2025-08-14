//
//  FCMClient.swift
//  Yakssok
//
//  Created by 김사랑 on 8/10/25.
//

import Foundation
import FirebaseMessaging
import UserNotifications
import ComposableArchitecture
import UIKit

struct FCMClient: Sendable {
    var setupFCM: @Sendable () async -> Void
    var sendTokenToServer: @Sendable () async throws -> Void
}

extension FCMClient: DependencyKey {
    static let liveValue = Self(
        setupFCM: {
            await FCMManager.shared.setupFCM()
        },
        sendTokenToServer: {
            try await FCMManager.shared.sendTokenToServer()
        }
    )
}

extension DependencyValues {
    var fcmClient: FCMClient {
        get { self[FCMClient.self] }
        set { self[FCMClient.self] = newValue }
    }
}

@MainActor
final class FCMManager: NSObject, ObservableObject, @unchecked Sendable {
    static let shared = FCMManager()

    private var isRegistering = false
    private var lastSentToken: String?

    private override init() {
        super.init()
    }

    func setupFCM() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }

    func sendTokenToServer() async throws {
        guard !isRegistering else {
            return
        }

        guard TokenManager.shared.isLoggedIn else {
            return
        }

        isRegistering = true
        defer { isRegistering = false }

        do {
            let fcmToken = try await Messaging.messaging().token()

            if lastSentToken == fcmToken {
                return
            }

            let deviceId = await UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

            let request = FCMTokenRequest(
                deviceId: deviceId,
                fcmToken: fcmToken,
                alertOn: true
            )

            let response: FCMTokenResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .registerDevice,
                method: .POST,
                body: request
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            lastSentToken = fcmToken
        } catch {
            throw APIError.fcmTokenNotFound
        }
    }
}

extension FCMManager: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let _ = fcmToken, TokenManager.shared.isLoggedIn {
            Task { @MainActor in
                try? await sendTokenToServer()
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension FCMManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await handleIncomingMessage(notification.request.content.userInfo)
        return [.banner, .sound, .badge]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await handleNotificationTap(response)
    }

    private func handleNotificationTap(_ response: UNNotificationResponse) async {
        // 추후 알림 탭 시 특정 화면으로 이동 등 처리
    }

    private func handleIncomingMessage(_ userInfo: [AnyHashable: Any]) async {
        if let data = userInfo["data"] as? [String: Any] {
            await handleDataOnlyMessage(data)
        }
    }

    private func handleDataOnlyMessage(_ data: [String: Any]) async {
        guard let title = data["title"] as? String,
              let body = data["body"] as? String,
              let soundTypeString = data["soundType"] as? String,
              let soundType = FCMSoundType(rawValue: soundTypeString) else {
            return
        }

        await createCustomNotification(title: title, body: body, soundType: soundType)
    }

    private func createCustomNotification(title: String, body: String, soundType: FCMSoundType) async {
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
