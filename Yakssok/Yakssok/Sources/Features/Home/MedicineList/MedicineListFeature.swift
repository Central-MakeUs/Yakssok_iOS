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
        var hasRoutinesEverRegistered: Bool = false
        var selectedUser: User? = nil
        var currentUser: User? = nil
        var selectedDate: Date = Date()
        var isLoading: Bool = false
        var error: String?

        var animatingMedicineId: String? = nil
        var animationDirection: AnimationDirection? = nil

        var medicineState: MedicineState {
            if !isViewingOwnMedicines {
                return .hasMedicines
            }
            if !hasRoutinesEverRegistered {
                return .noRoutines
            } else if todayMedicines.isEmpty && completedMedicines.isEmpty {
                return .noMedicineToday
            } else {
                return .hasMedicines
            }
        }

        var isViewingOwnMedicines: Bool {
            guard let selectedUser = selectedUser, let currentUser = currentUser else {
                return true
            }
            return selectedUser.id == currentUser.id
        }
    }

    enum AnimationDirection: Equatable {
        case toCompleted
        case toTodo
    }

    enum Action: Equatable {
        case onAppear
        case loadInitialData
        case routinesLoaded([MedicineRoutine])
        case medicineToggled(id: String)
        case addMedicineButtonTapped
        case loadMedicineData
        case medicineDataLoaded(MedicineDataResponse)
        case updateMedicines(todayMedicines: [Medicine], completedMedicines: [Medicine])
        case updateSelectedUser(User?)
        case updateCurrentUser(User)
        case updateSelectedDate(Date)
        case loadFriendMedicineData(friendId: Int)
        case friendMedicineDataLoaded(MedicineDataResponse)
        case loadingFailed(String)

        case startMedicineAnimation(medicineId: String, direction: AnimationDirection)
        case finishMedicineAnimation
        case rollbackMedicine(medicineId: String)
        case medicineApiSuccess(medicineId: String)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case addMedicineRequested
            case medicineStatusChanged
        }
    }

    @Dependency(\.medicineClient) var medicineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadInitialData)

            case .loadInitialData:
                state.isLoading = true
                state.error = nil
                return .run { [selectedDate = state.selectedDate] send in
                    do {
                        let routineResponse = try await medicineClient.loadMedicineData()
                        await send(.routinesLoaded(routineResponse.routines))

                        let today = Date()
                        let calendar = Calendar.current

                        let response: MedicineDataResponse
                        if calendar.isDate(selectedDate, inSameDayAs: today) {
                            response = try await medicineClient.loadTodaySchedules()
                        } else {
                            response = try await medicineClient.loadSchedulesForDateRange(selectedDate, selectedDate)
                        }

                        await send(.medicineDataLoaded(response))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .routinesLoaded(let routines):
                state.userMedicineRoutines = routines
                state.hasRoutinesEverRegistered = !routines.isEmpty
                return .none

            case .medicineDataLoaded(let response):
                state.todayMedicines = response.todayMedicines
                state.completedMedicines = response.completedMedicines
                state.isLoading = false
                return .none

            case .loadMedicineData:
                state.isLoading = true
                state.error = nil
                return .run { [selectedDate = state.selectedDate] send in
                    do {
                        let today = Date()
                        let calendar = Calendar.current

                        let response: MedicineDataResponse
                        if calendar.isDate(selectedDate, inSameDayAs: today) {
                            response = try await medicineClient.loadTodaySchedules()
                        } else {
                            response = try await medicineClient.loadSchedulesForDateRange(selectedDate, selectedDate)
                        }

                        await send(.medicineDataLoaded(response))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .updateSelectedUser(let user):
                state.selectedUser = user

                if let user = user, let friendId = Int(user.id), user.id != state.currentUser?.id {
                    return .send(.loadFriendMedicineData(friendId: friendId))
                } else if user?.id == state.currentUser?.id {
                    return .send(.loadMedicineData)
                }
                return .none

            case .updateSelectedDate(let date):
                state.selectedDate = date

                if let selectedUser = state.selectedUser,
                   let friendId = Int(selectedUser.id),
                   selectedUser.id != state.currentUser?.id {
                    return .send(.loadFriendMedicineData(friendId: friendId))
                } else {
                    return .send(.loadMedicineData)
                }

            case .loadFriendMedicineData(let friendId):
                state.isLoading = true
                state.error = nil
                return .run { [selectedDate = state.selectedDate] send in
                    do {
                        let today = Date()
                        let calendar = Calendar.current

                        let response: MedicineDataResponse
                        if calendar.isDate(selectedDate, inSameDayAs: today) {
                            response = try await medicineClient.loadFriendTodaySchedules(friendId)
                        } else {
                            response = try await medicineClient.loadFriendSchedulesForDateRange(friendId, selectedDate, selectedDate)
                        }

                        await send(.friendMedicineDataLoaded(response))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .friendMedicineDataLoaded(let response):
                state.todayMedicines = response.todayMedicines
                state.completedMedicines = response.completedMedicines
                state.isLoading = false
                return .none

            case .medicineToggled(let medicineId):
                guard state.isViewingOwnMedicines else { return .none }

                let today = Date()
                let calendar = Calendar.current
                let isToday = calendar.isDate(state.selectedDate, inSameDayAs: today)

                guard isToday, let scheduleId = Int(medicineId) else {
                    return .none
                }

                let direction = optimisticallyToggleMedicine(&state, medicineId)

                return .merge(
                    .send(.startMedicineAnimation(medicineId: medicineId, direction: direction)),

                    .run { send in
                        do {
                            try await medicineClient.takeMedicine(scheduleId)
                            await send(.medicineApiSuccess(medicineId: medicineId))
                            await send(.delegate(.medicineStatusChanged))
                        } catch {
                            await send(.rollbackMedicine(medicineId: medicineId))
                        }

                        try await Task.sleep(nanoseconds: 700_000_000)
                        await send(.finishMedicineAnimation)
                    }.cancellable(id: "medicineToggle-\(medicineId)")
                )

            case .startMedicineAnimation(let medicineId, let direction):
                state.animatingMedicineId = medicineId
                state.animationDirection = direction
                return .none

            case .finishMedicineAnimation:
                state.animatingMedicineId = nil
                state.animationDirection = nil
                return .none

            case .rollbackMedicine(let medicineId):
                rollbackMedicineOptimistically(&state, medicineId)
                return .none

            case .medicineApiSuccess(let medicineId):
                return .run { send in
                    await AppDataManager.shared.notifyDataChanged(.medicineUpdated)
                    await send(.delegate(.medicineStatusChanged))
                }

            case .addMedicineButtonTapped:
                return .send(.delegate(.addMedicineRequested))

            case let .updateMedicines(today, completed):
                state.todayMedicines = today
                state.completedMedicines = completed
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

// MARK: - Helper Functions
private func optimisticallyToggleMedicine(_ state: inout MedicineListFeature.State, _ medicineId: String) -> MedicineListFeature.AnimationDirection {
    if let index = state.todayMedicines.firstIndex(where: { $0.id == medicineId }) {
        let medicine = state.todayMedicines.remove(at: index)
        state.completedMedicines.append(medicine)
        return .toCompleted
    } else if let index = state.completedMedicines.firstIndex(where: { $0.id == medicineId }) {
        let medicine = state.completedMedicines.remove(at: index)
        state.todayMedicines.append(medicine)
        return .toTodo
    }
    return .toCompleted
}

private func rollbackMedicineOptimistically(_ state: inout MedicineListFeature.State, _ medicineId: String) {
    if let index = state.completedMedicines.firstIndex(where: { $0.id == medicineId }) {
        let medicine = state.completedMedicines.remove(at: index)
        state.todayMedicines.append(medicine)
    } else if let index = state.todayMedicines.firstIndex(where: { $0.id == medicineId }) {
        let medicine = state.todayMedicines.remove(at: index)
        state.completedMedicines.append(medicine)
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
