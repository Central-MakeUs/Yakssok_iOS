//
//  HomeView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    private let logoHeight: CGFloat = 19
    private let iconHeight: CGFloat = 24
    private let horizontalPadding: CGFloat = 16
    private let iconSpacing: CGFloat = 16
    private let verticalPadding: CGFloat = 16
    private let contentSpacing: CGFloat = 16

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                navigationBar(viewStore: viewStore)
                ScrollView {
                    LazyVStack(spacing: contentSpacing) {
                        IfLetStore(
                            store.scope(state: \.userSelection, action: \.userSelection),
                            then: MateSelectionView.init
                        )
                        .padding(.top, 10)
                    }.padding(.horizontal, 16)
                }
            }
        }
        .background(YKColor.Neutral.grey50)
    }

    private func navigationBar(viewStore: ViewStoreOf<HomeFeature>) -> some View {
        HStack {
            Image("logo-nav-bar")
                .resizable()
                .scaledToFit()
                .frame(height: logoHeight)
                .padding(.leading, horizontalPadding)

            Spacer()

            HStack(spacing: iconSpacing) {
                navigationButton(
                    imageName: "calendar-nav-bar",
                    action: { viewStore.send(.calendarTapped) }
                )
                navigationButton(
                    imageName: "notif-nav-bar",
                    action: { viewStore.send(.notificationTapped) }
                )
                navigationButton(
                    imageName: "menu-nav-bar",
                    action: { viewStore.send(.menuTapped) }
                )
            }
            .padding(.trailing, horizontalPadding)
        }
        .padding(.vertical, verticalPadding)
    }

    private func navigationButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(imageName)
                .frame(height: iconHeight)
        }
    }
}
