//
//  LoadingView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct LoadingView: View {
    let store: StoreOf<LoadingFeature>
    @State private var rotationAngle: Double = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                YKColor.Neutral.grey50
                    .ignoresSafeArea()

                VStack {
                    Image(viewStore.currentIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.easeInOut(duration: 0.3), value: viewStore.currentIconIndex)
                        .padding(.top, 260)

                    Spacer()
                }
            }
            .onChange(of: viewStore.currentIconIndex) { oldValue, newValue in
                startSingleRotation()
            }
        }
        .onAppear {
            store.send(.onAppear)
            startSingleRotation()
        }
    }

    private func startSingleRotation() {
        rotationAngle = 0
        withAnimation(.easeInOut(duration: 0.2)) {
            rotationAngle = 360
        }
    }
}
