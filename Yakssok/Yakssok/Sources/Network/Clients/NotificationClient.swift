//
//  NotificationClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture

struct NotificationClient {
    var loadNotifications: () async throws -> [NotificationItem]
    var registerDevice: @Sendable (FCMTokenRequest) async throws -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = Self(
        loadNotifications: {
            let response: NotificationListResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getNotifications,
                method: .GET,
                body: Optional<String>.none
            )

            guard response.code == 0 else {
                throw APIError.serverError(response.code)
            }

            return response.body.content.map { $0.toNotificationItem() }
        },
        registerDevice: { request in
            let _: FCMTokenResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .registerDevice,
                method: .POST,
                body: request
            )
        }
    )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
