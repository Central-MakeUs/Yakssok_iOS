//
//  FullCalendarFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import ComposableArchitecture
import Foundation

struct FullCalendarFeature: Reducer {
    struct State: Equatable {
        var currentDate: Date
        var selectedDate: Date
        var monthlyMedicineStatus: [String: MedicineStatus]
        var userSelection: MateSelectionFeature.State?
        var medicineList: MedicineListFeature.State?
        var calendarDays: [CalendarDay]

        var addRoutine: AddRoutineFeature.State?
        var notificationList: NotificationListFeature.State?
        var mateRegistration: MateRegistrationFeature.State?
        var myPage: MyPageFeature.State?

        var currentMonth: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: currentDate)
        }

        init(
            currentDate: Date = Date(),
            selectedDate: Date = Date(),
            userSelection: MateSelectionFeature.State? = .init(),
            medicineList: MedicineListFeature.State? = .init(),
            monthlyMedicineStatus: [String: MedicineStatus] = [:]
        ) {
            self.currentDate = currentDate
            self.selectedDate = selectedDate
            self.monthlyMedicineStatus = monthlyMedicineStatus
            self.userSelection = userSelection
            self.medicineList = medicineList
            self.calendarDays = generateCalendarDays(for: currentDate)
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case previousMonthTapped
        case nextMonthTapped
        case dayTapped(Date)
        case loadMonthlyData
        case monthlyDataLoaded([String: MedicineStatus])
        case updateMedicines(todayMedicines: [Medicine], completedMedicines: [Medicine])
        case backButtonTapped

        case notificationTapped
        case menuTapped
        case showAddRoutine
        case dismissAddRoutine
        case showNotificationList
        case dismissNotificationList
        case showMateRegistration
        case dismissMateRegistration
        case showMyPage
        case dismissMyPage

        case delegate(Delegate)
        case userSelection(MateSelectionFeature.Action)
        case medicineList(MedicineListFeature.Action)
        case addRoutine(AddRoutineFeature.Action)
        case notificationList(NotificationListFeature.Action)
        case mateRegistration(MateRegistrationFeature.Action)
        case myPage(MyPageFeature.Action)

        enum Delegate: Equatable {
            case backToHome
        }
    }

    @Dependency(\.fullCalendarMedicineClient) var fullCalendarMedicineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.calendarDays = generateCalendarDays(for: state.currentDate)
                return .merge(
                    .send(.loadMonthlyData),
                    .send(.userSelection(.onAppear)),
                    .send(.medicineList(.onAppear))
                )

            case .previousMonthTapped:
                state.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: state.currentDate) ?? state.currentDate
                state.calendarDays = generateCalendarDays(for: state.currentDate)
                return .send(.loadMonthlyData)

            case .nextMonthTapped:
                state.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: state.currentDate) ?? state.currentDate
                state.calendarDays = generateCalendarDays(for: state.currentDate)
                return .send(.loadMonthlyData)

            case .dayTapped(let date):
                state.selectedDate = date
                return .run { send in
                    do {
                        let response = try await fullCalendarMedicineClient.loadMedicineDataForDate(date)
                        await send(.medicineList(.medicineDataLoaded(response)))
                    } catch {
                        // 에러 처리
                    }
                }

            case .updateMedicines(let today, let completed):
                state.medicineList?.todayMedicines = today
                state.medicineList?.completedMedicines = completed
                return .none

            case .medicineList(.medicineToggled):
                updateMedicineStatus(&state)
                return .none

            case .loadMonthlyData:
                return .send(.monthlyDataLoaded(MockCalendarData.monthlyStatus))

            case .monthlyDataLoaded(let monthlyStatus):
                state.monthlyMedicineStatus = monthlyStatus
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backToHome))

            case .notificationTapped:
                return .send(.showNotificationList)

            case .menuTapped:
                return .send(.showMyPage)

            case .showAddRoutine:
                state.addRoutine = .init()
                return .none

            case .dismissAddRoutine:
                state.addRoutine = nil
                return .none

            case .showNotificationList:
                state.notificationList = .init()
                return .none

            case .dismissNotificationList:
                state.notificationList = nil
                return .none

            case .showMateRegistration:
                state.mateRegistration = .init()
                return .none

            case .dismissMateRegistration:
                state.mateRegistration = nil
                return .none

            case .showMyPage:
                state.myPage = .init()
                return .none

            case .dismissMyPage:
                state.myPage = nil
                return .none

            case .myPage(.delegate(.backToHome)):
                state.myPage = nil
                return .none

            case .userSelection(.addUserButtonTapped):
                return .send(.showMateRegistration)

            case .mateRegistration(.delegate(.mateAddingCompleted)):
                state.mateRegistration = nil
                return .send(.userSelection(.loadUsers))

            case .userSelection(.delegate(.addUserRequested)):
                return .send(.showMateRegistration)

            case .medicineList(.delegate(.addMedicineRequested)):
                return .send(.showAddRoutine)

            case .addRoutine(.dismissRequested):
                state.addRoutine = nil
                return .none

            case .addRoutine(.routineCompleted):
                state.addRoutine = nil
                return .send(.medicineList(.onAppear))

            case .notificationList(.backButtonTapped):
                state.notificationList = nil
                return .none

            case .mateRegistration(.backButtonTapped):
                state.mateRegistration = nil
                return .none

            case .delegate:
                return .none

            case .userSelection:
                return .none

            case .medicineList:
                return .none

            case .addRoutine:
                return .none

            case .notificationList:
                return .none

            case .mateRegistration:
                return .none

            case .myPage:
                return .none
            }
        }
        .ifLet(\.userSelection, action: \.userSelection) {
            MateSelectionFeature()
        }
        .ifLet(\.medicineList, action: \.medicineList) {
            MedicineListFeature()
        }
        .ifLet(\.addRoutine, action: \.addRoutine) {
            AddRoutineFeature()
        }
        .ifLet(\.notificationList, action: \.notificationList) {
            NotificationListFeature()
        }
        .ifLet(\.mateRegistration, action: \.mateRegistration) {
            MateRegistrationFeature()
        }
        .ifLet(\.myPage, action: \.myPage) {
            MyPageFeature()
        }
    }

    private func updateMedicineStatus(_ state: inout State) {
        let dateKey = formatDate(state.selectedDate)
        guard let medicineList = state.medicineList else { return }

        if medicineList.todayMedicines.isEmpty && !medicineList.completedMedicines.isEmpty {
            state.monthlyMedicineStatus[dateKey] = .completed
        } else if !medicineList.todayMedicines.isEmpty {
            state.monthlyMedicineStatus[dateKey] = .incomplete
        } else {
            state.monthlyMedicineStatus[dateKey] = Optional.none
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private func generateCalendarDays(for date: Date) -> [CalendarDay] {
    let calendar = Calendar.current
    let today = Date()

    guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
    let firstOfMonth = monthInterval.start
    let numberOfDaysInMonth = calendar.component(.day, from: calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth)!)

    var days: [CalendarDay] = []

    for day in 1...numberOfDaysInMonth {
        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
        days.append(CalendarDay(
            date: dayDate,
            day: day,
            isCurrentMonth: true,
            isToday: calendar.isDate(dayDate, inSameDayAs: today)
        ))
    }

    return days
}

