//
//  NotificationListView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/18/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct NotificationListView: View {
    let store: StoreOf<NotificationListFeature>

    var body: some View {
        NavigationView {
            ZStack {
                YKColor.Neutral.grey100
                    .ignoresSafeArea(.all)

                WithViewStore(store, observe: { $0 }) { viewStore in
                    YKNavigationBar(
                        title: "알림",
                        hasBackButton: true,
                        onBackTapped: {
                            viewStore.send(.backButtonTapped)
                        }
                    ) {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewStore.notifications) { notification in
                                    NotificationBubbleView(notification: notification)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .scrollDisabled(false)
                        .clipped()
                        .onAppear {
                            viewStore.send(.onAppear)
                        }
                    }
                }
            }
        }
    }
}

private struct NotificationContentView: View {
    let store: StoreOf<NotificationListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let error = viewStore.error {
                ErrorView(message: error) {
                    viewStore.send(.loadNotifications)
                }
            } else if viewStore.notifications.isEmpty {
                EmptyNotificationView()
            } else {
                NotificationListContentView(notifications: viewStore.notifications)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private struct NotificationListContentView: View {
    let notifications: [NotificationItem]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Constants.itemSpacing) {
                ForEach(notifications) { notification in
                    NotificationBubbleView(notification: notification)
                }
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
    }
}

private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("알림을 불러올 수 없습니다")
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey900)
            Text(message)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey500)
                .multilineTextAlignment(.center)
            Button("다시 시도", action: onRetry)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Primary.primary400)
        }
        .padding(.horizontal, 32)
    }
}

private struct EmptyNotificationView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("notification-empty")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(YKColor.Neutral.grey300)
            Text("알림이 없습니다")
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey500)
        }
    }
}

private enum Constants {
    static let horizontalPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 16
}
