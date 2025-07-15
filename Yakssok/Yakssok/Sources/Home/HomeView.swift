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
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    NavigationBarView(store: store)
                    MainContentView(store: store)
                }
                IfLetStore(store.scope(state: \.messageModal, action: \.messageModal)) { modalStore in
                    MessageModalView(store: modalStore)
                }
                IfLetStore(store.scope(state: \.reminderModal, action: \.reminderModal)) { modalStore in
                    ReminderModalView(store: modalStore)
                }
                IfLetStore(store.scope(state: \.addRoutine, action: \.addRoutine)) { addRoutineStore in
                    AddRoutineView(store: addRoutineStore)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

private struct NavigationBarView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                LogoView()
                Spacer()
                NavigationButtons(store: store)
            }
            .padding(.vertical, Layout.navigationVerticalPadding)
            .background(YKColor.Neutral.grey50)
        }
    }
}

private struct LogoView: View {
    var body: some View {
        Image("logo-nav-bar")
            .resizable()
            .scaledToFit()
            .frame(height: Layout.logoHeight)
            .padding(.leading, Layout.horizontalPadding)
    }
}

private struct NavigationButtons: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
}

private struct MainContentView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                BackgroundColor(shouldShowMateCards: viewStore.shouldShowMateCards)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: Layout.contentSpacing) {
                        if viewStore.shouldShowMateCards {
                            MateCardsSection(store: store)
                            BottomContentSection(store: store, hasBackground: true)
                        } else {
                            BottomContentSection(store: store, hasBackground: false)
                        }
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }
        }
    }
}

private struct BackgroundColor: View {
    let shouldShowMateCards: Bool

    var body: some View {
        (shouldShowMateCards ? YKColor.Neutral.grey100 : YKColor.Neutral.grey50)
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

private struct BottomContentSection: View {
    let store: StoreOf<HomeFeature>
    let hasBackground: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MateSelectionSection(store: store, hasBackground: hasBackground)
            CalendarSection(store: store)
            MedicineListSection(store: store)
        }
        .background(hasBackground ? YKColor.Neutral.grey50 : Color.clear)
        .if(hasBackground) { view in
            view.cornerRadius(Layout.cornerRadius, corners: [.topLeft, .topRight])
        }
    }
}

private struct MateSelectionSection: View {
    let store: StoreOf<HomeFeature>
    let hasBackground: Bool

    var body: some View {
        IfLetStore(store.scope(state: \.userSelection, action: \.userSelection)) {
            MateSelectionView(store: $0)
        }
        .padding(.top, hasBackground ? Layout.userSelectionTopPaddingWithBackground : Layout.userSelectionTopPadding)
    }
}

private struct CalendarSection: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        IfLetStore(store.scope(state: \.calendar, action: \.calendar)) {
            CalendarView(store: $0)
        }
        .padding(.top, Layout.calendarTopPadding)
    }
}

private struct MedicineListSection: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        IfLetStore(store.scope(state: \.medicineList, action: \.medicineList)) {
            MedicineListView(store: $0)
        }
        .padding(.top, Layout.MedicineListTopPadding)
        .padding(.bottom, Layout.MedicineListBottomPadding)
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
    static let calendarTopPadding: CGFloat = 17.5
    static let MedicineListTopPadding: CGFloat = 40
    static let MedicineListBottomPadding: CGFloat = 100
    static let cornerRadius: CGFloat = 32
}
