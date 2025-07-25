//
//  FullCalendarView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct FullCalendarView: View {
    let store: StoreOf<FullCalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(spacing: 0) {
                    FullCalendarNavigationBar(
                        onBackTapped: { viewStore.send(.backButtonTapped) },
                        onNotificationTapped: { viewStore.send(.notificationTapped) },
                        onMenuTapped: { viewStore.send(.menuTapped) }
                    )
                    .padding(.horizontal, 16)

                    ScrollView {
                        VStack(spacing: 0) {
                            IfLetStore(
                                store.scope(state: \.userSelection, action: \.userSelection)
                            ) { userSelectionStore in
                                MateSelectionView(store: userSelectionStore)
                            }
                            .padding(.top, 10)

                            calendarSection(viewStore: viewStore)

                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)

                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity, minHeight: 8, maxHeight: 8)
                                .background(YKColor.Neutral.grey100)

                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)

                            IfLetStore(
                                store.scope(state: \.medicineList, action: \.medicineList)
                            ) { medicineStore in
                                MedicineListView(store: medicineStore)
                            }
                        }
                    }
                }
                .background(YKColor.Neutral.grey50)

                IfLetStore(store.scope(state: \.addRoutine, action: \.addRoutine)) { addRoutineStore in
                    AddRoutineView(store: addRoutineStore)
                }
                IfLetStore(store.scope(state: \.notificationList, action: \.notificationList)) { notificationStore in
                    NotificationListView(store: notificationStore)
                }
                IfLetStore(store.scope(state: \.mateRegistration, action: \.mateRegistration)) { mateRegistrationStore in
                    MateRegistrationView(store: mateRegistrationStore)
                }
                IfLetStore(store.scope(state: \.myPage, action: \.myPage)) { myPageStore in
                    MyPageView(store: myPageStore)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    @ViewBuilder
    private func calendarSection(viewStore: ViewStoreOf<FullCalendarFeature>) -> some View {
        VStack(spacing: 16) {
            MonthNavigationView(
                currentMonth: viewStore.currentMonth,
                onPreviousTapped: { viewStore.send(.previousMonthTapped) },
                onNextTapped: { viewStore.send(.nextMonthTapped) }
            )

            CalendarWeekdayHeaderView()
            
            CalendarGridView(
                days: viewStore.calendarDays,
                selectedDate: viewStore.selectedDate,
                monthlyStatus: viewStore.monthlyMedicineStatus,
                onDayTapped: { date in
                    viewStore.send(.dayTapped(date))
                }
            )
        }
        .padding(.horizontal, 16)
    }
}
