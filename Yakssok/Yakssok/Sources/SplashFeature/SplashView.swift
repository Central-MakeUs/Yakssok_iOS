//
//  SplashView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct SplashView: View {
    let store: StoreOf<SplashFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                YKColor.Primary.primary400
                    .ignoresSafeArea()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
