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
            // 메이트를 선택한 경우에는 항상 hasMedicines 상태로 처리
            if !isViewingOwnMedicines {
                return .hasMedicines
            }

            // "나"를 선택한 경우
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
        case toCompleted  // 먹을 약 -> 복용 완료
        case toTodo      // 복용 완료 -> 먹을 약
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

            case .routinesLoaded(let routines):
                state.userMedicineRoutines = routines
                state.hasRoutinesEverRegistered = !routines.isEmpty
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

            case .medicineToggled(let medicineId):
                guard state.isViewingOwnMedicines else { return .none }

                let today = Date()
                let calendar = Calendar.current
                let isToday = calendar.isDate(state.selectedDate, inSameDayAs: today)

                guard isToday else {
                    return .none
                }

                guard let scheduleId = Int(medicineId) else {
                    return .none
                }

                // 애니메이션 방향 결정
                let direction: AnimationDirection
                if state.todayMedicines.contains(where: { $0.id == medicineId }) {
                    direction = .toCompleted
                } else {
                    direction = .toTodo
                }

                // 애니메이션 시작
                return .merge(
                    .send(.startMedicineAnimation(medicineId: medicineId, direction: direction)),
                    .run { send in
                        // 0.3초 후에 실제 API 호출
                        try await Task.sleep(nanoseconds: 300_000_000)

                        do {
                            try await medicineClient.takeMedicine(scheduleId)
                            let todayResponse = try await medicineClient.loadTodaySchedules()
                            await send(.medicineDataLoaded(todayResponse))
                        } catch {
                            do {
                                let todayResponse = try await medicineClient.loadTodaySchedules()
                                await send(.medicineDataLoaded(todayResponse))
                            } catch {
                                await send(.loadingFailed(error.localizedDescription))
                            }
                        }
                        await send(.finishMedicineAnimation)
                    }
                )

            case .startMedicineAnimation(let medicineId, let direction):
                state.animatingMedicineId = medicineId
                state.animationDirection = direction
                return .none

            case .finishMedicineAnimation:
                state.animatingMedicineId = nil
                state.animationDirection = nil
                return .none

            case .addMedicineButtonTapped:
                return .send(.delegate(.addMedicineRequested))

            case .medicineDataLoaded(let response):
                state.todayMedicines = response.todayMedicines
                state.completedMedicines = response.completedMedicines
                state.isLoading = false
                return .none

            case let .updateMedicines(todayMedicines, completedMedicines):
                state.todayMedicines = todayMedicines
                state.completedMedicines = completedMedicines
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
