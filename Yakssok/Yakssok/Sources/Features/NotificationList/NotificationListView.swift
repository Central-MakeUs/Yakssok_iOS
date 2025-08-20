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
                    if viewStore.isLoading {
                        LoadingView(store: Store(initialState: LoadingFeature.State(
                            nickname: "",
                            authorizationCode: ""
                        )) {
                            LoadingFeature()
                        })
                    } else {
                        YKNavigationBar(
                            title: "알림",
                            hasBackButton: true,
                            onBackTapped: { viewStore.send(.backButtonTapped) }
                        ) {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack(spacing: Constants.itemSpacing) {
                                        ForEach(viewStore.notifications) { notification in
                                            NotificationBubbleView(notification: notification)
                                                .id(notification.id)
                                        }
                                    }
                                    .padding(.horizontal, Constants.horizontalPadding)
                                    .padding(.bottom, 50)
                                    .animation(nil, value: viewStore.notifications)
                                }
                                .defaultScrollAnchor(.bottom)
                                .onAppear {
                                    if let last = viewStore.notifications.last {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                                .onChange(of: viewStore.notifications) { notifications in
                                    if let last = notifications.last {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            proxy.scrollTo(last.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private enum Constants {
    static let horizontalPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 16
}
