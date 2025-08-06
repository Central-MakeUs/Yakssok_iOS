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
                            .padding(.bottom, 50)
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

private enum Constants {
    static let horizontalPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 16
}
