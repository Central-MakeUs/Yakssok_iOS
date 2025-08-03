//
//  NotificationClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture

struct NotificationClient {
    var loadNotifications: () async throws -> [NotificationItem]
}

extension NotificationClient: DependencyKey {
    static let liveValue = Self(
        loadNotifications: {
            do {
                let response: NotificationListResponse = try await APIClient.shared.request(
                    endpoint: .getNotifications,
                    method: .GET,
                    body: Optional<String>.none
                )

                guard response.code == 0 else {
                    throw APIError.serverError(response.code)
                }

                return response.body.content.map { $0.toNotificationItem() }
            } catch {
                // API 실패 시 빈 배열 반환
                return []
            }
        }
    )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
