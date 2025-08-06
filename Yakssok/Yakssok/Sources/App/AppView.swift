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
        }
    }
}
