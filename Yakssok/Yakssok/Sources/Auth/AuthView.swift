//
//  AuthView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct AuthView: View {
    let store: StoreOf<AuthFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.login != nil {
                    IfLetStore(store.scope(state: \.login, action: \.login), then: LoginView.init)
                } else if viewStore.onboarding != nil {
                    IfLetStore(store.scope(state: \.onboarding, action: \.onboarding), then: OnboardingView.init)
                }
            }
        }
    }
}
