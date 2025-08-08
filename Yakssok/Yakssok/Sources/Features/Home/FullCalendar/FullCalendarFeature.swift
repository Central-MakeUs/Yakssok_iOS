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
        var currentUserNickname: String?
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
        case loadUserProfile
        case userProfileLoaded(UserProfileResponse)
        case userProfileLoadFailed(String)

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

        case dataChanged(DataChangeEvent)
        case startDataSubscription
        case stopDataSubscription

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

    @Dependency(\.medicineClient) var medicineClient
    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce(handleAction)
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

    private func handleAction(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.calendarDays = generateCalendarDays(for: state.currentDate)

            return .merge(
                .send(.loadUserProfile),
                .send(.loadMonthlyData),
                .send(.startDataSubscription),
                .send(.userSelection(.onAppear)),
                .send(.medicineList(.onAppear))
            )

        case .startDataSubscription:
            return .run { send in
                await AppDataManager.shared.subscribe(id: "fullcalendar-subscription") { event in
                    await send(.dataChanged(event))
                }
            }
            .cancellable(id: "fullcalendar-subscription")

        case .stopDataSubscription:
            return .run { _ in
                await AppDataManager.shared.unsubscribe(id: "fullcalendar-subscription")
            }
            .cancellable(id: "fullcalendar-subscription", cancelInFlight: true)

        case .dataChanged(let event):
            switch event {
            case .medicineAdded, .medicineUpdated, .medicineDeleted, .allDataChanged:
                return .send(.loadMonthlyData)
                    .debounce(id: "reload-calendar", for: 0.3, scheduler: DispatchQueue.main)
            case .mateAdded, .mateRemoved:
                return .send(.userSelection(.loadUsers))
                    .debounce(id: "reload-users", for: 0.3, scheduler: DispatchQueue.main)
            case .profileUpdated:
                return .send(.loadUserProfile)
                    .debounce(id: "reload-userprofile", for: 0.3, scheduler: DispatchQueue.main)
            }

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
            return .send(.medicineList(.updateSelectedDate(date)))

        case .updateMedicines(let today, let completed):
            state.medicineList?.todayMedicines = today
            state.medicineList?.completedMedicines = completed
            return .none

        case .medicineList(.medicineToggled):
            updateCurrentDateStatus(&state)
            return .none

        case .loadMonthlyData:
            return .run { [currentDate = state.currentDate, selectedUser = state.userSelection?.selectedUser, currentUser = state.userSelection?.currentUser] send in
                do {
                    let calendar = Calendar.current
                    guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
                        await send(.monthlyDataLoaded([:]))
                        return
                    }

                    let startOfMonth = monthInterval.start
                    let endOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end

                    let monthlyStatus: [String: MedicineStatus]

                    // 선택된 사용자에 따라 다른 API 호출
                    if let selectedUser = selectedUser,
                       let friendId = Int(selectedUser.id),
                       selectedUser.id != currentUser?.id {
                        // 친구의 월간 데이터 로드
                        monthlyStatus = try await medicineClient.loadFriendMonthlyStatus(friendId, startOfMonth, endOfMonth)
                    } else {
                        // 본인의 월간 데이터 로드
                        monthlyStatus = try await medicineClient.loadMonthlyStatus(startOfMonth, endOfMonth)
                    }

                    await send(.monthlyDataLoaded(monthlyStatus))
                } catch {
                    await send(.monthlyDataLoaded([:]))
                }
            }

        case .monthlyDataLoaded(let monthlyStatus):
            state.monthlyMedicineStatus = monthlyStatus
            return .none

        case .backButtonTapped:
            return .merge(
                .send(.stopDataSubscription),
                .send(.delegate(.backToHome))
            )

        case .loadUserProfile:
            return .run { send in
                do {
                    let response = try await userClient.loadUserProfile()
                    await send(.userProfileLoaded(response))
                } catch {
                    await send(.userProfileLoadFailed(error.localizedDescription))
                }
            }

        case .userProfileLoaded(let response):
            let currentUser = response.toCurrentUser()
            state.currentUserNickname = response.body.nickname
            return .merge(
                .send(.medicineList(.updateCurrentUser(currentUser))),
                .send(.userSelection(.updateCurrentUser(currentUser)))
            )

        case .userProfileLoadFailed:
            let defaultUser = User.defaultCurrentUser()

            return .merge(
                .send(.medicineList(.updateCurrentUser(defaultUser))),
                .send(.userSelection(.updateCurrentUser(defaultUser)))
            )

        case .notificationTapped:
            return .send(.showNotificationList)

        case .menuTapped:
            return .send(.showMyPage)

        case .showAddRoutine:
            let userName = state.currentUserNickname ?? ""
            var addRoutineState = AddRoutineFeature.State()
            addRoutineState.categorySelection?.userNickname = userName
            state.addRoutine = addRoutineState
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
            let userName = state.userSelection?.currentUser?.name ?? ""
            state.mateRegistration = MateRegistrationFeature.State(currentUserName: userName)
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

        case .userSelection(.delegate(.userSelectionChanged(let user))):
            return .merge(
                .send(.medicineList(.updateSelectedUser(user))),
                .send(.loadMonthlyData)
            )

        case .userSelection(.userSelected):
            return .none

        case .userSelection(.addUserButtonTapped):
            return .send(.showMateRegistration)

        case .mateRegistration(.delegate(.mateAddingCompleted)):
            state.mateRegistration = nil
            return .none

        case .userSelection(.delegate(.addUserRequested)):
            return .send(.showMateRegistration)

        case .medicineList(.delegate(.addMedicineRequested)):
            return .send(.showAddRoutine)

        case .addRoutine(.dismissRequested):
            state.addRoutine = nil
            return .none

        case .addRoutine(.routineSubmissionSucceeded):
            state.addRoutine = nil
            return .none

        case .notificationList(.backButtonTapped):
            state.notificationList = nil
            return .none

        case .mateRegistration(.backButtonTapped):
            state.mateRegistration = nil
            return .none

        case .delegate, .userSelection, .medicineList, .addRoutine, .notificationList, .mateRegistration, .myPage:
            return .none
        }
    }

    private func updateCurrentDateStatus(_ state: inout State) {
        let dateKey = formatDate(state.selectedDate)
        guard let medicineList = state.medicineList else { return }

        if medicineList.todayMedicines.isEmpty && !medicineList.completedMedicines.isEmpty {
            state.monthlyMedicineStatus[dateKey] = .completed
        } else if !medicineList.todayMedicines.isEmpty {
            state.monthlyMedicineStatus[dateKey] = .incomplete
        } else {
            state.monthlyMedicineStatus[dateKey] = .none
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
