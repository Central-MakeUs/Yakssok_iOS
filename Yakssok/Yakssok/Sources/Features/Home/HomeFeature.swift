//
//  HomeFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import Foundation
import ComposableArchitecture
import WidgetKit

struct HomeFeature: Reducer {
    struct State: Equatable {
        var currentUser: User?
        var currentUserNickname: String?
        var selectedDate: Date = Date()
        var userSelection: MateSelectionFeature.State? = .init()
        var mateCards: MateCardsFeature.State? = .init()
        var weeklyCalendar: WeeklyCalendarFeature.State? = .init()
        var medicineList: MedicineListFeature.State? = .init()
        var messageModal: MessageModalFeature.State?
        var reminderModal: ReminderModalFeature.State?
        var addRoutine: AddRoutineFeature.State?
        var notificationList: NotificationListFeature.State?
        var mateRegistration: MateRegistrationFeature.State?
        var myPage: MyPageFeature.State?
        var fullCalendar: FullCalendarFeature.State?
        var hasShownReminderToday: Bool = false

        var isLoadingMyPage: Bool = false
        var isLoadingFullCalendar: Bool = false
        var isLoadingNotifications: Bool = false

        var shouldShowMateCards: Bool {
            mateCards?.cards.isEmpty == false
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case onResume
        case loadUserProfile
        case userProfileLoaded(UserProfileResponse)
        case userProfileLoadFailed(String)
        case notificationTapped
        case menuTapped
        case checkMissedMedicines
        case showReminderModal([Medicine])
        case dismissReminderModal
        case startDataSubscription
        case stopDataSubscription

        case preloadMyPageData
        case myPageDataLoaded(UserProfileResponse)
        case myPagePreloadFailed(String)
        case preloadFullCalendarData
        case fullCalendarDataLoaded([User], [String: MedicineStatus], [CalendarDay], MedicineDataResponse)
        case fullCalendarPreloadFailed(String)
        case preloadNotificationData
        case notificationDataLoaded([NotificationItem])
        case notificationPreloadFailed(String)

        case userSelection(MateSelectionFeature.Action)
        case mateCards(MateCardsFeature.Action)
        case weeklyCalendar(WeeklyCalendarFeature.Action)
        case medicineList(MedicineListFeature.Action)
        case messageModal(MessageModalFeature.Action)
        case showMessageModal(targetUser: String, targetUserId: Int, messageType: MessageType)
        case dismissMessageModal
        case reminderModal(ReminderModalFeature.Action)
        case addRoutine(AddRoutineFeature.Action)
        case showAddRoutine
        case dismissAddRoutine
        case notificationList(NotificationListFeature.Action)
        case showNotificationList
        case dismissNotificationList
        case mateRegistration(MateRegistrationFeature.Action)
        case showMateRegistration
        case dismissMateRegistration
        case myPage(MyPageFeature.Action)
        case fullCalendar(FullCalendarFeature.Action)
        case showMyPage
        case dismissMyPage
        case refreshMedicineList
        case refreshAllData
        case notificationPermissionChanged(Bool)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case logoutCompleted
            case withdrawalCompleted
        }
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.medicineClient) var medicineClient
    @Dependency(\.notificationClient) var notificationClient

    var body: some ReducerOf<Self> {
        Reduce(handleAction)
            .ifLet(\.userSelection, action: \.userSelection) {
                MateSelectionFeature()
            }
            .ifLet(\.mateCards, action: \.mateCards) {
                MateCardsFeature()
            }
            .ifLet(\.weeklyCalendar, action: \.weeklyCalendar) {
                WeeklyCalendarFeature()
            }
            .ifLet(\.medicineList, action: \.medicineList) {
                MedicineListFeature()
            }
            .ifLet(\.messageModal, action: \.messageModal) {
                MessageModalFeature()
            }
            .ifLet(\.reminderModal, action: \.reminderModal) {
                ReminderModalFeature()
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
            .ifLet(\.fullCalendar, action: \.fullCalendar) {
                FullCalendarFeature()
            }
    }

    private func handleAction(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .merge(
                handleOnAppear(&state),
                .send(.startDataSubscription),
                .run { send in
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send(.checkMissedMedicines)
                },
                .run { send in
                    try await Task.sleep(nanoseconds: 2_000_000_000)

                    NotificationPermissionManager.shared.onPermissionChanged = { granted in
                        Task { @MainActor in
                            await send(.notificationPermissionChanged(granted))
                        }
                    }
                    await NotificationPermissionManager.shared.checkAndHandlePermissionOnAppEntry()
                }
            )

        case .onResume:
            return .run { send in
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await send(.loadUserProfile) }
                    group.addTask { await send(.medicineList(.loadInitialData)) }
                    group.addTask { await send(.mateCards(.loadCards)) }
                }
            }

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
            state.currentUser = currentUser
            state.currentUserNickname = response.body.nickname
            return .merge(
                .send(.medicineList(.updateCurrentUser(currentUser))),
                .send(.userSelection(.updateCurrentUser(currentUser)))
            )

        case .userProfileLoadFailed:
            return .merge(
                .send(.stopDataSubscription),
                .send(.delegate(.logoutCompleted))
            )

        case .startDataSubscription:
            return .run { send in
                await AppDataManager.shared.subscribe(id: "home") { event in
                    switch event {
                    case .medicineAdded, .medicineUpdated, .medicineDeleted:
                        await send(.refreshAllData)
                    case .mateAdded, .mateRemoved:
                        await send(.refreshAllData)
                    case .profileUpdated:
                        await send(.loadUserProfile)
                    case .allDataChanged:
                        await send(.refreshAllData)
                    }
                }
            }

        case .stopDataSubscription:
            return .run { _ in
                await AppDataManager.shared.unsubscribe(id: "home")
            }
            .cancellable(id: "home-subscription", cancelInFlight: true)

        case .checkMissedMedicines:
            guard !state.hasShownReminderToday else { return .none }

            return .run { send in
                guard let medicineData = try? await medicineClient.loadTodaySchedules() else {
                    return
                }

                let missedMedicines = ReminderModalFeature.getMissedMedicines(from: medicineData)

                if !missedMedicines.isEmpty {
                    await send(.showReminderModal(missedMedicines))
                }
            }

        case .showReminderModal(let missedMedicines):
            guard let userName = state.currentUserNickname else {
                return .none
            }

            state.reminderModal = ReminderModalFeature.State(
                userName: userName,
                missedMedicines: missedMedicines
            )
            state.hasShownReminderToday = true
            return .none

        case .reminderModal(.delegate(.dismissed)):
            state.reminderModal = nil
            return .none

        case .reminderModal(.delegate(.navigateToHome)):
            state.reminderModal = nil
            return .send(.medicineList(.loadInitialData))

        case .dismissReminderModal:
            state.reminderModal = nil
            return .none

        case .notificationTapped:
            guard !state.isLoadingNotifications else { return .none }

            state.isLoadingNotifications = true
            return .send(.preloadNotificationData)

        // 마이페이지 프리로딩
        case .menuTapped:
            guard !state.isLoadingMyPage else { return .none }

            state.isLoadingMyPage = true
            return .send(.preloadMyPageData)

        case .preloadMyPageData:
            return .run { send in
                do {
                    let response = try await userClient.loadUserProfile()
                    await send(.myPageDataLoaded(response))
                } catch {
                    await send(.myPagePreloadFailed(error.localizedDescription))
                }
            }

        case .myPageDataLoaded(let response):
            state.isLoadingMyPage = false

            // 마이페이지 상태를 미리 준비된 데이터로 초기화
            var myPageState = MyPageFeature.State()
            myPageState.userProfile = UserProfile(
                name: response.body.nickname,
                profileImage: response.body.profileImageUrl,
                relationship: nil
            )
            myPageState.medicineCount = response.body.medicationCount
            myPageState.mateCount = response.body.followingCount

            // 알림 설정 복원
            let hasToggleSetting = UserDefaults.standard.object(forKey: "userNotificationToggle") != nil
            let savedToggle = UserDefaults.standard.bool(forKey: "userNotificationToggle")
            myPageState.alertOn = hasToggleSetting ? savedToggle : true

            state.myPage = myPageState

            return .run { _ in
                if let imageUrl = response.body.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    await ImageCache.shared.prefetch(url)
                }
            }

        case .myPagePreloadFailed(let error):
            state.isLoadingMyPage = false
            state.myPage = .init()
            return .none

        // 캘린더 프리로딩
        case .weeklyCalendar(.delegate(.showFullCalendar)):
            guard !state.isLoadingFullCalendar else { return .none }

            state.isLoadingFullCalendar = true
            return .send(.preloadFullCalendarData)

        // 풀 캘린더 페이지 프리로딩
        case .preloadFullCalendarData:
            return .run { [currentUser = state.currentUser] send in
                do {
                    let currentDate = Date()
                    let calendar = Calendar.current

                    // 캘린더에서는 항상 '나'의 데이터로 먼저 로드
                    async let usersTask = userClient.loadUsers()

                    async let monthlyStatusTask: [String: MedicineStatus] = {
                        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
                            return [:]
                        }
                        let startOfMonth = monthInterval.start
                        let endOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end

                        return try await medicineClient.loadMonthlyStatus(startOfMonth, endOfMonth)
                    }()

                    async let routineDataTask = medicineClient.loadMedicineData()

                    async let medicineDataTask: MedicineDataResponse = {
                        return try await medicineClient.loadTodaySchedules()
                    }()

                    let users = try await usersTask
                    let monthlyStatus = try await monthlyStatusTask
                    let routineData = try await routineDataTask
                    let medicineData = try await medicineDataTask
                    let calendarDays = generateCalendarDays(for: currentDate)

                    let completeMedicineData = MedicineDataResponse(
                        routines: routineData.routines,
                        todayMedicines: medicineData.todayMedicines,
                        completedMedicines: medicineData.completedMedicines
                    )

                    await send(.fullCalendarDataLoaded(users, monthlyStatus, calendarDays, completeMedicineData))
                } catch {
                    await send(.fullCalendarPreloadFailed(error.localizedDescription))
                }
            }

        case .fullCalendarDataLoaded(let users, let monthlyStatus, let calendarDays, let medicineData):
            state.isLoadingFullCalendar = false

            // 풀 캘린더 상태를 미리 준비된 데이터로 초기화
            var fullCalendarState = FullCalendarFeature.State(
                currentDate: Date(),
                selectedDate: Date(),
                monthlyMedicineStatus: monthlyStatus
            )

            // 캘린더에서는 항상 '나'로 리셋함
            var userSelectionState = MateSelectionFeature.State()
            userSelectionState.users = users
            userSelectionState.currentUser = state.currentUser
            if let currentUser = state.currentUser {
                userSelectionState.selectedUserId = currentUser.id
            }
            fullCalendarState.userSelection = userSelectionState

            // 약 리스트 상태 설정 (내 약 데이터로 설정)
            var medicineListState = MedicineListFeature.State()
            medicineListState.currentUser = state.currentUser
            medicineListState.selectedUser = state.currentUser
            medicineListState.selectedDate = Date()
            medicineListState.todayMedicines = medicineData.todayMedicines
            medicineListState.completedMedicines = medicineData.completedMedicines
            medicineListState.userMedicineRoutines = medicineData.routines
//            medicineListState.hasRoutinesEverRegistered = !medicineData.routines.isEmpty
             if !medicineData.routines.isEmpty {
                 medicineListState.hasRoutinesEverRegistered = true
             }
            medicineListState.isPreloaded = true
            fullCalendarState.medicineList = medicineListState

            fullCalendarState.calendarDays = calendarDays
            fullCalendarState.currentUserNickname = state.currentUserNickname

            state.fullCalendar = fullCalendarState
            return .none

        case .fullCalendarPreloadFailed(let error):
            state.isLoadingFullCalendar = false
            state.fullCalendar = FullCalendarFeature.State()
            return .none

        // 알림 리스트 프리로딩
        case .preloadNotificationData:
            return .run { send in
                do {
                    let notifications = try await notificationClient.loadNotifications()
                    await send(.notificationDataLoaded(notifications))
                } catch {
                    await send(.notificationPreloadFailed(error.localizedDescription))
                }
            }

        case .notificationDataLoaded(let notifications):
            state.isLoadingNotifications = false

            var notificationState = NotificationListFeature.State()
            notificationState.notifications = notifications.sorted { $0.timestamp < $1.timestamp }

            state.notificationList = notificationState
            return .none

        case .notificationPreloadFailed(let error):
            state.isLoadingNotifications = false
            state.notificationList = .init()
            return .none

        // MARK: - Show/Dismiss Actions
        case .showMyPage:
            // 이미 데이터가 로드된 상태에서는 바로 표시
            if state.myPage == nil {
                state.myPage = .init()
            }
            return .none

        case .dismissMyPage:
            state.myPage = nil
            return .none

        case .showMessageModal(let targetUser, let targetUserId, let messageType):
            return handleShowMessageModal(&state, targetUser: targetUser, targetUserId: targetUserId, messageType: messageType)

        case .dismissMessageModal:
            state.messageModal = nil
            return .none

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
            // 이미 데이터가 로드된 상태에서는 바로 표시
            if state.notificationList == nil {
                state.notificationList = .init()
            }
            return .none

        case .dismissNotificationList:
            state.notificationList = nil
            return .none

        case .showMateRegistration:
            let userName = state.currentUserNickname ?? ""
            state.mateRegistration = .init(currentUserName: userName)
            return .none

        case .dismissMateRegistration:
            state.mateRegistration = nil
            return .none

        // MARK: - User Selection & Calendar
        case .userSelection(.delegate(.userSelectionChanged(let user))):
            // 메이트 선택 시 해당 유저의 약 데이터 프리로딩
            if let selectedUser = user, let friendId = Int(selectedUser.id), selectedUser.id != state.currentUser?.id {
                return .merge(
                    .send(.medicineList(.updateSelectedUser(user))),
                    .run { send in
                        // 친구의 오늘 약 데이터 프리로딩
                        do {
                            let friendMedicineData = try await medicineClient.loadFriendTodaySchedules(friendId)
                            await send(.medicineList(.friendMedicineDataLoaded(friendMedicineData)))
                        } catch {
                            // error
                        }
                    }
                )
            } else {
                return .send(.medicineList(.updateSelectedUser(user)))
            }

        case .userSelection(.userSelected):
            return .none

        case .weeklyCalendar(.dateSelected(let date)):
            state.selectedDate = date
            return .send(.medicineList(.updateSelectedDate(date)))

        case .medicineList(.medicineDataLoaded(let response)):
            return .run { _ in
                await MainActor.run {
                    AppDataSharingManager.shared.updateWidgetMedicineData(response.todayMedicines)
                }
            }

        case .medicineList(.delegate(.medicineStatusChanged)):
            return .merge(
                .send(.mateCards(.loadCards)),
                .run { _ in
                    await MainActor.run {
                        WidgetCenter.shared.reloadTimelines(ofKind: "YakssokWidget")
                    }
                }
            )

        case .medicineList(.medicineApiSuccess(let medicineId)):
            return .run { _ in
                await MainActor.run {
                    AppDataSharingManager.shared.updateMedicineCompletion(medicineId: medicineId)
                }
            }

        // MARK: - Delegate Actions
        case .myPage(.delegate(.backToHome)):
            state.myPage = nil
            return .send(.refreshAllData)

        case .weeklyCalendar(.delegate(.showFullCalendar)):
            guard !state.isLoadingFullCalendar else { return .none }

            state.isLoadingFullCalendar = true
            return .send(.preloadFullCalendarData)

        case .fullCalendar(.delegate(.backToHome)):
            state.fullCalendar = nil
            return .send(.refreshAllData)

        case .userSelection(.addUserButtonTapped):
            return .send(.showMateRegistration)

        case .mateRegistration(.delegate(.mateAddingCompleted)):
            state.mateRegistration = nil
            return .none

        case .userSelection(.delegate(.addUserRequested)):
            return .send(.showMateRegistration)

        case .mateCards(.delegate(.showMessageModal(let targetUser, let targetUserId, let messageType))):
            return .send(.showMessageModal(targetUser: targetUser, targetUserId: targetUserId, messageType: messageType))

        case .medicineList(.delegate(.addMedicineRequested)):
            return .send(.showAddRoutine)

        case .myPage(.delegate(.logoutCompleted)):
            state.myPage = nil
            // 로그아웃 시 위젯 데이터 초기화
            return .merge(
                .send(.delegate(.logoutCompleted)),
                .run { _ in
                    await MainActor.run {
                        AppDataSharingManager.shared.clearWidgetData()
                    }
                }
            )

        case .myPage(.delegate(.withdrawalCompleted)):
            state.myPage = nil
            // 회원탈퇴 시 위젯 데이터 초기화
            return .merge(
                .send(.delegate(.withdrawalCompleted)),
                .run { _ in
                    await MainActor.run {
                        AppDataSharingManager.shared.clearWidgetData()
                    }
                }
            )

        case .notificationPermissionChanged(let granted):
            if state.myPage != nil {
                return .send(.myPage(.notificationPermissionChecked(granted)))
            }
            return .none

        // MARK: - Modal Close Actions
        case .reminderModal(.takeMedicineNowTapped), .reminderModal(.closeButtonTapped):
            state.reminderModal = nil
            return .none

        case .messageModal(.closeButtonTapped):
            state.messageModal = nil
            return .none

        case .messageModal(.sendingCompleted):
            // 메시지 전송 완료 시 해당 카드 삭제
            let targetUserId = state.messageModal?.targetUserId
            state.messageModal = nil

            if let userId = targetUserId {
                return .send(.mateCards(.messageWasSent(targetUserId: String(userId))))
            }
            return .none

        case .addRoutine(.dismissRequested):
            state.addRoutine = nil
            return .none

        case .addRoutine(.routineCompleted):
            state.addRoutine = nil
            return .none

        case .notificationList(.backButtonTapped):
            state.notificationList = nil
            return .none

        case .mateRegistration(.backButtonTapped):
            state.mateRegistration = nil
            return .none

        case .refreshMedicineList:
            return .send(.medicineList(.loadMedicineData))

        case .refreshAllData:
            return refreshAllComponentsData(&state)

        // MARK: - Child Feature Actions
        case .userSelection, .mateCards, .weeklyCalendar, .medicineList,
                .messageModal, .reminderModal, .addRoutine, .notificationList,
                .mateRegistration, .myPage, .fullCalendar, .delegate:
            return .none
        }
    }

    private func handleOnAppear(_ state: inout State) -> Effect<Action> {
        return .run { send in
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await send(.weeklyCalendar(.onAppear)) }
                group.addTask { await send(.loadUserProfile) }
                group.addTask { await send(.userSelection(.loadUsers)) }
                group.addTask { await send(.mateCards(.loadCards)) }
                group.addTask { await send(.medicineList(.loadInitialData)) }
            }
        }
    }

    private func refreshAllComponentsData(_ state: inout State) -> Effect<Action> {
        return .run { [selectedUser = state.userSelection?.selectedUser] send in
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await send(.loadUserProfile) }
                group.addTask { await send(.userSelection(.loadUsers)) }
                group.addTask { await send(.mateCards(.loadCards)) }

                // 선택된 유저가 있으면 해당 유저 데이터도 업데이트
                if let user = selectedUser {
                    group.addTask { await send(.medicineList(.updateSelectedUser(user))) }
                } else {
                    group.addTask { await send(.medicineList(.loadInitialData)) }
                }
            }
        }
    }

    private func handleShowMessageModal(
        _ state: inout State,
        targetUser: String,
        targetUserId: Int,
        messageType: MessageType
    ) -> Effect<Action> {
        guard let card = state.mateCards?.cards.first(where: { $0.userName == targetUser }) else {
            return .none
        }

        let medicines = messageType == .nagging ?
        card.todayMedicines :   // 못 먹은 약
        card.completedMedicines // 먹은 약

        let medicineCount = medicines.count

        state.messageModal = MessageModalFeature.State(
            targetUser: targetUser,
            targetUserId: targetUserId,
            messageType: messageType,
            medicineCount: medicineCount,
            relationship: card.relationship,
            medicines: medicines,
            profileImageURL: card.profileImage
        )
        return .none
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
