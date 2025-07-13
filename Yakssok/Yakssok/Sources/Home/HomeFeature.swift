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
        var shouldShowMateCards: Bool {
            mateCards?.cards.isEmpty == false
        }
        var messageModal: MessageModalFeature.State?
        var reminderModal: ReminderModalFeature.State?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case calendarTapped
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
    }

    private func handleOnAppear() -> Effect<Action> {
        return .merge(
            .send(.mateCards(.onAppear)),
            .send(.calendar(.onAppear)),
            .send(.showReminderModal)
        )
    }

    private func handleShowMissedMedicineModal(_ state: inout State) -> Effect<Action> {
        let testMedicines = [
            Medicine(id: "1", name: "종합 비타민 오쏘몰", dosage: nil, time: "9:00 am", color: .purple),
            Medicine(id: "2", name: "오메가3", dosage: nil, time: "9:00 am", color: .yellow),
            Medicine(id: "3", name: "비타민 D", dosage: nil, time: "12:00 pm", color: .blue),
            Medicine(id: "4", name: "마그네슘", dosage: nil, time: "6:00 pm", color: .green),
            Medicine(id: "5", name: "프로바이오틱스", dosage: nil, time: "9:00 pm", color: .pink),
            Medicine(id: "6", name: "칼슘", dosage: nil, time: "10:00 pm", color: .purple)
        ]
        state.reminderModal = ReminderModalFeature.State(
            userName: "김00",
            missedMedicines: testMedicines
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
        let medicineCount = Self.getMedicineCount(for: targetUser, messageType: messageType, state: state)
        let testMedicineData = MockMedicineData.medicineData(for: .hasMedicines)
        let medicines = messageType == .nagging ?
        testMedicineData.todayMedicines :
        testMedicineData.completedMedicines

        state.messageModal = MessageModalFeature.State(
            targetUser: targetUser,
            messageType: messageType,
            medicineCount: medicineCount,
            relationship: card.relationship,
            medicines: medicines
        )
        return .none
    }

    private static func getMedicineCount(for targetUser: String, messageType: MessageType, state: State) -> Int {
        guard let card = state.mateCards?.cards.first(where: { $0.userName == targetUser }) else {
            return 0
        }
        switch (card.status, messageType) {
        case (.missedMedicine(let count), .nagging):
            return count
        case (.completed, .encouragement):
            return 2
        default:
            return 0
        }
    }

    private func handleAction(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return handleOnAppear()
        case .calendarTapped, .notificationTapped, .menuTapped:
            return .none
        case .showReminderModal:
            return handleShowMissedMedicineModal(&state)
        case .showMessageModal(let targetUser, let messageType):
            return handleShowMessageModal(&state, targetUser: targetUser, messageType: messageType)
        case .reminderModal(.takeMedicineNowTapped),
                .reminderModal(.closeButtonTapped):
            state.reminderModal = nil
            return .none
        case .messageModal(.closeButtonTapped),
                .messageModal(.sendButtonTapped):
            state.messageModal = nil
            return .none
        case .mateCards(.delegate(.showMessageModal(let targetUser, let messageType))):
            return .send(.showMessageModal(targetUser: targetUser, messageType: messageType))
        case .dismissMessageModal:
            state.messageModal = nil
            return .none
        case .userSelection, .mateCards, .calendar, .medicineList, .messageModal, .reminderModal:
            return .none
        }
    }
}
