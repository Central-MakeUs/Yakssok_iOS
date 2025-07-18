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
        var selectedDate: Date = Date()
        var userSelection: MateSelectionFeature.State? = .init()
        var mateCards: MateCardsFeature.State? = .init()
        var calendar: CalendarFeature.State? = .init()
        var medicineList: MedicineListFeature.State? = .init()
        var messageModal: MessageModalFeature.State?
        var reminderModal: ReminderModalFeature.State?
        var addRoutine: AddRoutineFeature.State?
        var notificationList: NotificationListFeature.State?
        var shouldShowMateCards: Bool {
            mateCards?.cards.isEmpty == false
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case notificationTapped
        case menuTapped
        case userSelection(MateSelectionFeature.Action)
        case mateCards(MateCardsFeature.Action)
        case calendar(CalendarFeature.Action)
        case medicineList(MedicineListFeature.Action)
        case messageModal(MessageModalFeature.Action)
        case showMessageModal(targetUser: String, messageType: MessageType)
        case dismissMessageModal
        case reminderModal(ReminderModalFeature.Action)
        case showReminderModal
        case addRoutine(AddRoutineFeature.Action)
        case showAddRoutine
        case dismissAddRoutine
        case notificationList(NotificationListFeature.Action)
        case showNotificationList
        case dismissNotificationList
    }

    var body: some ReducerOf<Self> {
        Reduce(handleAction)
            .ifLet(\.userSelection, action: \.userSelection) {
                MateSelectionFeature()
            }
            .ifLet(\.mateCards, action: \.mateCards) {
                MateCardsFeature()
            }
            .ifLet(\.calendar, action: \.calendar) {
                CalendarFeature()
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
    }

    private func handleAction(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return handleOnAppear()
        case .notificationTapped:
            return .send(.showNotificationList)
        case .menuTapped:
            return .none
        case .showReminderModal:
            return handleShowMissedMedicineModal(&state)
        case .showMessageModal(let targetUser, let messageType):
            return handleShowMessageModal(&state, targetUser: targetUser, messageType: messageType)
        case .reminderModal(.takeMedicineNowTapped), .reminderModal(.closeButtonTapped):
            state.reminderModal = nil
            return .none
        case .messageModal(.closeButtonTapped), .messageModal(.sendButtonTapped):
            state.messageModal = nil
            return .none
        case .mateCards(.delegate(.showMessageModal(let targetUser, let messageType))):
            return .send(.showMessageModal(targetUser: targetUser, messageType: messageType))
        case .dismissMessageModal:
            state.messageModal = nil
            return .none
        case .medicineList(.delegate(.addMedicineRequested)):
            return .send(.showAddRoutine)
        case .showAddRoutine:
            state.addRoutine = .init()
            return .none
        case .addRoutine(.dismissRequested):
            state.addRoutine = nil
            return .none
        case .addRoutine(.routineCompleted):
            state.addRoutine = nil
            return .send(.medicineList(.onAppear))
        case .dismissAddRoutine:
            state.addRoutine = nil
            return .none
        case .showNotificationList:
            state.notificationList = .init()
            return .none
        case .notificationList(.backButtonTapped):
            state.notificationList = nil
            return .none
        case .dismissNotificationList:
            state.notificationList = nil
            return .none
        case .userSelection, .mateCards, .calendar, .medicineList,
                .messageModal, .reminderModal, .addRoutine, .notificationList:
            return .none
        }
    }

    private func handleOnAppear() -> Effect<Action> {
        return .merge(
            .send(.mateCards(.onAppear)),
            .send(.calendar(.onAppear)),
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
        messageType: MessageType
    ) -> Effect<Action> {
        guard let card = state.mateCards?.cards.first(where: { $0.userName == targetUser }) else {
            return .none
        }

        let medicineCount = getMedicineCount(for: card, messageType: messageType)
        let mockData = MockMedicineData.medicineData(for: .hasMedicines)
        let medicines = messageType == .nagging ?
        mockData.todayMedicines :
        mockData.completedMedicines

        state.messageModal = MessageModalFeature.State(
            targetUser: targetUser,
            messageType: messageType,
            medicineCount: medicineCount,
            relationship: card.relationship,
            medicines: medicines
        )
        return .none
    }

    private func getMedicineCount(for card: MateCard, messageType: MessageType) -> Int {
        switch (card.status, messageType) {
        case (.missedMedicine(let count), .nagging):
            return count
        case (.completed, .encouragement):
            return 2
        default:
            return 0
        }
    }
}
