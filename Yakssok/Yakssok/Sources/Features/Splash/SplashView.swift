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

    private let logoTopSpacing: CGFloat = 295
    private let logoBottomSpacing: CGFloat = 373

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                YKColor.Primary.primary400
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                        .frame(height: logoTopSpacing)
                    Image("logo-splash")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                        .frame(height: logoBottomSpacing)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
