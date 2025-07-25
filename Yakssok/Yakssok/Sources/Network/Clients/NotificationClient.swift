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
            // TODO: 실제 API 구현 - GET /notifications
            return MockNotificationData.notifications(for: .sample)
        }
    )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
