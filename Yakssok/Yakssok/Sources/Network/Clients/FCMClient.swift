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
    var unregister: @Sendable () async -> Void
}

extension FCMClient: DependencyKey {
    static let liveValue = Self(
        setupFCM: {
            await FCMManager.shared.setupFCM()
        },
        sendTokenToServer: {
            try await FCMManager.shared.sendTokenToServer()
        },
        unregister: {
            await FCMManager.shared.unregister()
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
final class FCMManager: NSObject, ObservableObject {
    static let shared = FCMManager()

    private var isRegistering = false
    private var lastSentToken: String?

    private override init() {
        super.init()
    }

    func setupFCM() {
        // FCM 초기 설정
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

        // FCM 토큰 가져오기 (최대 3번 시도)
        var fcmToken: String?
        for attempt in 1...3 {
            do {
                fcmToken = try await Messaging.messaging().token()

                if let token = fcmToken, !token.isEmpty {
                    break
                } else {
                    if attempt < 3 {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                    }
                }
            } catch {
                if attempt < 3 {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
            }
        }

        guard let validToken = fcmToken, !validToken.isEmpty else {
            throw APIError.fcmTokenNotFound
        }

        // 이전과 동일한 토큰이면 스킵
        if lastSentToken == validToken {
            return
        }

        let deviceId = DeviceIdManager.shared.stableDeviceId
        let request = FCMTokenRequest(
            deviceId: deviceId,
            fcmToken: validToken,
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

        lastSentToken = validToken
    }

    func unregister() async {
        do {
            let deviceId = DeviceIdManager.shared.stableDeviceId

            // 서버에서 해제 (alertOn: false)
            let request = FCMTokenRequest(
                deviceId: deviceId,
                fcmToken: lastSentToken ?? "",
                alertOn: false
            )

            let _: FCMTokenResponse? = try? await APIClient.shared.requestWithTokenRefresh(
                endpoint: .registerDevice,
                method: .POST,
                body: request
            )

            // Firebase에서 토큰 삭제
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                Messaging.messaging().deleteToken { error in
                    cont.resume()
                }
            }

            // 캐시 정리
            lastSentToken = nil

        } catch {
            // Handle unregister error
        }
    }
}
