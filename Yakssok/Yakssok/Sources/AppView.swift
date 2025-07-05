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
        WithViewStore(self.store, observe: { $0 }) { ViewStore in
            IfLetStore(
                store.scope(state: \.splash, action: \.splash),
                then: { splashStore in
                    SplashView(store: splashStore)
                },
                else: {
                    LoginView()
                }
            )
        }
    }
}
