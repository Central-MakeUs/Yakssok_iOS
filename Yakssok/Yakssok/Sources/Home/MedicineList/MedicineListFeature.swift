//
//  MedicineListFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MedicineListFeature {
    struct State: Equatable {
        var userMedicineRoutines: [MedicineRoutine] = []
        var todayMedicines: [Medicine] = []
        var completedMedicines: [Medicine] = []
        var selectedUser: User? = nil
        var currentUser: User? = nil
        var isLoading: Bool = false
        var error: String?

        var medicineState: MedicineState {
            if userMedicineRoutines.isEmpty {
                return .noRoutines
            } else if todayMedicines.isEmpty && completedMedicines.isEmpty {
                return .noMedicineToday
            } else {
                return .hasMedicines
            }
        }

        // TODO: 백엔드 연동 시 ID 기반 비교로 변경 필요
        var isViewingOwnMedicines: Bool {
            // 임시: 이름 기반 비교
            guard let selectedUser = selectedUser, let currentUser = currentUser else {
                return true
            }
            return selectedUser.name == currentUser.name && currentUser.name == "나"
        }
    }

    enum Action: Equatable {
        case onAppear
        case medicineToggled(id: String)
        case addMedicineButtonTapped
        case loadMedicineData
        case medicineDataLoaded(MedicineDataResponse)
        case updateMedicines(todayMedicines: [Medicine], completedMedicines: [Medicine])
        case updateSelectedUser(User?)
        case updateCurrentUser(User)
        case loadingFailed(String)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case addMedicineRequested
        }
    }

    @Dependency(\.medicineClient) var medicineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadMedicineData)

            case .loadMedicineData:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let response = try await medicineClient.loadMedicineData()
                        await send(.medicineDataLoaded(response))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .medicineToggled(let medicineId):
                // 본인의 약이 아닌 경우 토글 불가
                guard state.isViewingOwnMedicines else { return .none }

                if let index = state.todayMedicines.firstIndex(where: { $0.id == medicineId }) {
                    let medicine = state.todayMedicines.remove(at: index)
                    state.completedMedicines.append(medicine)
                } else if let index = state.completedMedicines.firstIndex(where: { $0.id == medicineId }) {
                    let medicine = state.completedMedicines.remove(at: index)
                    state.todayMedicines.append(medicine)
                }
                return .none

            case .addMedicineButtonTapped:
                return .send(.delegate(.addMedicineRequested))

            case .medicineDataLoaded(let response):
                state.userMedicineRoutines = response.routines
                state.todayMedicines = response.todayMedicines
                state.completedMedicines = response.completedMedicines
                state.isLoading = false
                return .none

            case let .updateMedicines(todayMedicines, completedMedicines):
                state.todayMedicines = todayMedicines
                state.completedMedicines = completedMedicines
                return .none

            case .updateSelectedUser(let user):
                state.selectedUser = user
                return .none

            case .updateCurrentUser(let user):
                state.currentUser = user
                return .none

            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

enum MedicineState: Equatable {
    case noRoutines
    case noMedicineToday
    case hasMedicines
}

struct MedicineDataResponse: Equatable {
    let routines: [MedicineRoutine]
    let todayMedicines: [Medicine]
    let completedMedicines: [Medicine]
}
