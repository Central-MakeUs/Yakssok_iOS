//
//  AppView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/3/25.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>

    @State private var inviteCode = ""
    @State private var presentMateRegistration = false

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.splash != nil {
                    IfLetStore(store.scope(state: \.splash, action: \.splash), then: SplashView.init)
                } else if viewStore.auth != nil {
                    IfLetStore(store.scope(state: \.auth, action: \.auth), then: AuthView.init)
                } else {
                    IfLetStore(store.scope(state: \.home, action: \.home), then: HomeView.init)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: APIClient.tokenExpiredNotification)) { _ in
                viewStore.send(.tokenExpired)
            }
            .onReceive(NotificationCenter.default.publisher(for: DeepLinkManager.notification)) { note in
                handleDeepLinkNotification(note, isLoggedIn: viewStore.home != nil)
            }
            .onChange(of: viewStore.home != nil) { _, isHome in
                handleLoginStateChange(isHome: isHome)
            }
            .fullScreenCover(isPresented: $presentMateRegistration) {
                MateRegistrationScreen(inviteCode: inviteCode, isPresented: $presentMateRegistration)
            }
        }
    }

    private func handleDeepLinkNotification(_ note: Notification, isLoggedIn: Bool) {
        guard let info = note.userInfo as? [String: Any] else { return }

        handleDeepLink(info, isLoggedIn: isLoggedIn) {
            DeepLinkCache.shared.store(info)
        }
    }

    private func handleLoginStateChange(isHome: Bool) {
        guard isHome, let cached = DeepLinkCache.shared.consume() else { return }
        handleDeepLink(cached, isLoggedIn: true, onDefer: {})
    }

    private func handleDeepLink(
        _ info: [String: Any],
        isLoggedIn: Bool,
        onDefer: () -> Void
    ) {
        switch info.deepLinkTarget {
        case .mateInvite(let code):
            if isLoggedIn {
                inviteCode = code
                presentMateRegistration = true
            } else {
                onDefer()
            }
        case .unknown:
            break
        }
    }
}

private struct MateRegistrationScreen: View {
    let inviteCode: String
    @Binding var isPresented: Bool

    var body: some View {
        let mateStore = Store(
            initialState: MateRegistrationFeature.State(currentUserName: ""),
            reducer: { MateRegistrationFeature() }
        )

        MateRegistrationView(store: mateStore)
            .onAppear {
                NotificationCenter.default.post(
                    name: Notification.Name("yakssok.mate.prefill"),
                    object: nil,
                    userInfo: ["code": inviteCode]
                )
            }
            .onReceive(
                NotificationCenter.default.publisher(for: Notification.Name("yakssok.mate.completed"))
            ) { _ in
                isPresented = false
            }
    }
}
