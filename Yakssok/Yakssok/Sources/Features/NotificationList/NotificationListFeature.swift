//
//  NotificationListFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/18/25.
//

import ComposableArchitecture
import Foundation

struct NotificationListFeature: Reducer {
    struct State: Equatable {
        var notifications: [NotificationItem] = []
        var isLoading: Bool = false
        var error: String?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case loadNotifications
        case notificationsLoaded([NotificationItem])
        case loadingFailed(String)
        case backButtonTapped
    }

    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadNotifications)
            case .loadNotifications:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let notifications = try await notificationClient.loadNotifications()
                        try await clock.sleep(for: .milliseconds(300))
                        await send(.notificationsLoaded(notifications))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
            case .notificationsLoaded(let notifications):
                state.notifications = notifications.sorted { $0.timestamp < $1.timestamp }
                state.isLoading = false
                return .none
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
            case .backButtonTapped:
                return .none
            }
        }
    }
}
