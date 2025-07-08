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

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                NavigationBarView(store: store)
                MainContentView(store: store)
            }
        }
    }
}

private struct NavigationBarView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                logoView
                Spacer()
                navigationButtons(viewStore: viewStore)
            }
            .padding(.vertical, Layout.navigationVerticalPadding)
            .background(YKColor.Neutral.grey50)
        }
    }

    private var logoView: some View {
        Image("logo-nav-bar")
            .resizable()
            .scaledToFit()
            .frame(height: Layout.logoHeight)
            .padding(.leading, Layout.horizontalPadding)
    }

    private func navigationButtons(viewStore: ViewStoreOf<HomeFeature>) -> some View {
        HStack(spacing: Layout.iconSpacing) {
            NavigationButton(imageName: "calendar-nav-bar") {
                viewStore.send(.calendarTapped)
            }
            NavigationButton(imageName: "notif-nav-bar") {
                viewStore.send(.notificationTapped)
            }
            NavigationButton(imageName: "menu-nav-bar") {
                viewStore.send(.menuTapped)
            }
        }
        .padding(.trailing, Layout.horizontalPadding)
    }
}

private struct MainContentView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                backgroundColor(shouldShowMateCards: viewStore.shouldShowMateCards)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: Layout.contentSpacing) {
                        if viewStore.shouldShowMateCards {
                            MateCardsSection(store: store)
                            UserSelectionSection(store: store, hasBackground: true)
                        } else {
                            UserSelectionSection(store: store, hasBackground: false)
                        }
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }
        }
    }

    private func backgroundColor(shouldShowMateCards: Bool) -> Color {
        shouldShowMateCards ? YKColor.Neutral.grey100 : YKColor.Neutral.grey50
    }
}

private struct MateCardsSection: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        IfLetStore(store.scope(state: \.mateCards, action: \.mateCards)) {
            MateCardsView(store: $0)
                .padding(.top, Layout.mateCardsTopPadding)
                .padding(.bottom, Layout.mateCardsBottomPadding)
        }
    }
}

private struct UserSelectionSection: View {
    let store: StoreOf<HomeFeature>
    let hasBackground: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            IfLetStore(store.scope(state: \.userSelection, action: \.userSelection)) {
                MateSelectionView(store: $0)
            }
            .padding(.top, hasBackground ? Layout.userSelectionTopPaddingWithBackground : Layout.userSelectionTopPadding)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(hasBackground ? YKColor.Neutral.grey50 : Color.clear)
        .if(hasBackground) { view in
            view.cornerRadius(Layout.cornerRadius, corners: [.topLeft, .topRight])
        }
    }
}

private struct NavigationButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .frame(height: Layout.iconHeight)
        }
    }
}

private enum Layout {
    static let logoHeight: CGFloat = 19
    static let iconHeight: CGFloat = 24
    static let horizontalPadding: CGFloat = 16
    static let iconSpacing: CGFloat = 16
    static let navigationVerticalPadding: CGFloat = 16
    static let contentSpacing: CGFloat = 4
    static let mateCardsTopPadding: CGFloat = 16
    static let mateCardsBottomPadding: CGFloat = 12
    static let userSelectionTopPadding: CGFloat = 10
    static let userSelectionTopPaddingWithBackground: CGFloat = 32
    static let cornerRadius: CGFloat = 32
}
