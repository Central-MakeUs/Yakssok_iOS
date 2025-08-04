//
//  HomeFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import Foundation
import ComposableArchitecture

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
        case userSelection(MateSelectionFeature.Action)
        case mateCards(MateCardsFeature.Action)
        case weeklyCalendar(WeeklyCalendarFeature.Action)
        case medicineList(MedicineListFeature.Action)
        case messageModal(MessageModalFeature.Action)
        case showMessageModal(targetUser: String, targetUserId: Int, messageType: MessageType)
        case dismissMessageModal
        case reminderModal(ReminderModalFeature.Action)
        case showReminderModal
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
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case logoutCompleted
            case withdrawalCompleted
        }
    }

    @Dependency(\.userClient) var userClient

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
            return handleOnAppear(&state)

        case .onResume:
            return .merge(
                .send(.loadUserProfile),
                .send(.medicineList(.loadInitialData)),
                .send(.mateCards(.loadCards))
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
            state.currentUser = currentUser
            state.currentUserNickname = response.body.nickname
            return .merge(
                .send(.medicineList(.updateCurrentUser(currentUser))),
                .send(.userSelection(.updateCurrentUser(currentUser)))
            )

        case .userProfileLoadFailed(let error):
            let defaultUser = User.defaultCurrentUser()
            state.currentUser = defaultUser
            return .send(.medicineList(.updateCurrentUser(defaultUser)))

        case .notificationTapped:
            return .send(.showNotificationList)

        case .menuTapped:
            return .send(.showMyPage)

        // MARK: - Show/Dismiss Actions
        case .showMyPage:
            state.myPage = .init()
            return .none

        case .dismissMyPage:
            state.myPage = nil
            return .none

        case .showReminderModal:
            return handleShowMissedMedicineModal(&state)

        case .showMessageModal(let targetUser, let targetUserId, let messageType):
            return handleShowMessageModal(&state, targetUser: targetUser, targetUserId: targetUserId, messageType: messageType)

        case .dismissMessageModal:
            state.messageModal = nil
            return .none

        case .showAddRoutine:
            state.addRoutine = .init()
            return .none

        case .dismissAddRoutine:
            state.addRoutine = nil
            return .send(.onResume)

        case .showNotificationList:
            state.notificationList = .init()
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
            return .send(.medicineList(.updateSelectedUser(user)))

        case .userSelection(.userSelected):
            return .none

        case .weeklyCalendar(.dateSelected(let date)):
            state.selectedDate = date
            return .send(.medicineList(.updateSelectedDate(date)))

        // MARK: - Delegate Actions
        case .myPage(.delegate(.backToHome)):
            state.myPage = nil
            return .send(.onResume)

        case .weeklyCalendar(.delegate(.showFullCalendar)):
            state.fullCalendar = FullCalendarFeature.State()
            return .none

        case .fullCalendar(.delegate(.backToHome)):
            state.fullCalendar = nil
            return .send(.onResume)

        case .userSelection(.addUserButtonTapped):
            return .send(.showMateRegistration)

        case .mateRegistration(.delegate(.mateAddingCompleted)):
            state.mateRegistration = nil
            return .merge(
                .send(.userSelection(.loadUsers)),
                .send(.mateCards(.loadCards))
            )

        case .userSelection(.delegate(.addUserRequested)):
            return .send(.showMateRegistration)

        case .mateCards(.delegate(.showMessageModal(let targetUser, let targetUserId, let messageType))):
            return .send(.showMessageModal(targetUser: targetUser, targetUserId: targetUserId, messageType: messageType))

        case .medicineList(.delegate(.addMedicineRequested)):
            return .send(.showAddRoutine)

        case .myPage(.delegate(.logoutCompleted)):
            state.myPage = nil
            return .send(.delegate(.logoutCompleted))

        case .myPage(.delegate(.withdrawalCompleted)):
            state.myPage = nil
            return .send(.delegate(.withdrawalCompleted))

        // MARK: - Modal Close Actions
        case .reminderModal(.takeMedicineNowTapped), .reminderModal(.closeButtonTapped):
            state.reminderModal = nil
            return .none

        case .messageModal(.closeButtonTapped), .messageModal(.sendingCompleted):
            state.messageModal = nil
            return .none

        case .addRoutine(.dismissRequested):
            state.addRoutine = nil
            return .send(.refreshMedicineList)

        case .addRoutine(.routineCompleted):
            state.addRoutine = nil
            return .send(.refreshMedicineList)

        case .notificationList(.backButtonTapped):
            state.notificationList = nil
            return .none

        case .mateRegistration(.backButtonTapped):
            state.mateRegistration = nil
            return .none

        case .refreshMedicineList:
            return .send(.medicineList(.loadMedicineData))

        // MARK: - Child Feature Actions
        case .userSelection, .mateCards, .weeklyCalendar, .medicineList,
                .messageModal, .reminderModal, .addRoutine, .notificationList,
                .mateRegistration, .myPage, .fullCalendar, .delegate:
            return .none
        }
    }

    private func handleOnAppear(_ state: inout State) -> Effect<Action> {
        return .merge(
            .send(.loadUserProfile),
            .send(.mateCards(.onAppear)),
            .send(.weeklyCalendar(.onAppear)),
            .send(.showReminderModal)
        )
    }

    private func handleShowMissedMedicineModal(_ state: inout State) -> Effect<Action> {
        let mockData = MockMedicineData.medicineData(for: .hasMedicines)
        state.reminderModal = ReminderModalFeature.State(
            userName: "김00",
            missedMedicines: mockData.todayMedicines
        )
        return .none
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
            medicines: medicines
        )
        return .none
    }
}
