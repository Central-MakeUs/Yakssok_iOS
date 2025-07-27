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

        var medicineState: MedicineState {
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

                // 선택된 사용자가 바뀌면 해당 사용자의 데이터를 로드
                if let user = user, let friendId = Int(user.id), user.id != state.currentUser?.id {
                    return .send(.loadFriendMedicineData(friendId: friendId))
                } else if user?.id == state.currentUser?.id {
                    // 본인을 선택한 경우 본인 데이터 로드
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

                guard let scheduleId = Int(medicineId) else {
                    return .none
                }

                return .run { send in
                    do {
                        try await medicineClient.takeMedicine(scheduleId)
                        await send(.loadMedicineData)
                    } catch {
                        await send(.loadMedicineData)
                    }
                }

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

            case .updateSelectedUser(let user):
                state.selectedUser = user
                return .none

            case .updateCurrentUser(let user):
                state.currentUser = user
                return .none

            case .updateSelectedDate(let date):
                state.selectedDate = date
                return .send(.loadMedicineData)

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

// MARK: - API Response Conversion
private func convertToMedicineDataResponse(_ apiResponse: MedicationListResponse, selectedDate: Date) -> MedicineDataResponse {
    var allTodayMedicines: [Medicine] = []
    var allCompletedMedicines: [Medicine] = []
    var routines: [MedicineRoutine] = []

    for medicationCard in apiResponse.body.medicationCardResponses {
        let (todayMedicines, completedMedicines) = medicationCard.toMedicineDataResponse(for: selectedDate)
        allTodayMedicines.append(contentsOf: todayMedicines)
        allCompletedMedicines.append(contentsOf: completedMedicines)

        let routine = MedicineRoutine(
            id: UUID().uuidString,
            medicineName: medicationCard.medicineName,
            schedule: medicationCard.intakeTimes.map { convertTimeToDisplayFormat($0) },
            category: convertAPITypeToCategory(medicationCard.medicationType),
            frequency: convertToMedicineFrequency(
                intakeDays: medicationCard.intakeDays,
                intakeTimes: medicationCard.intakeTimes
            ),
            startDate: nil,
            endDate: nil,
            createdAt: Date(),
            status: convertAPIStatusToMedicineStatus(medicationCard.medicationStatus)
        )
        routines.append(routine)
    }

    return MedicineDataResponse(
        routines: routines,
        todayMedicines: allTodayMedicines,
        completedMedicines: allCompletedMedicines
    )
}

private func convertTimeToDisplayFormat(_ timeString: String) -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm:ss"

    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = "a h:mm"
    displayFormatter.locale = Locale(identifier: "ko_KR")

    if let time = timeFormatter.date(from: timeString) {
        return displayFormatter.string(from: time)
    }
    return timeString
}

private func convertAPITypeToCategory(_ apiType: String) -> MedicineCategory {
    let categoryId: String
    switch apiType {
    case "MENTAL": categoryId = "mental"
    case "BEAUTY": categoryId = "beauty"
    case "CHRONIC": categoryId = "chronic"
    case "DIET": categoryId = "diet"
    case "TEMPORARY": categoryId = "pain"
    case "SUPPLEMENT": categoryId = "supplement"
    case "OTHER": categoryId = "other"
    default: categoryId = "other"
    }

    return MedicineCategory.defaultCategories.first { $0.id == categoryId }
    ?? MedicineCategory.defaultCategories.last!
}

private func convertToMedicineFrequency(intakeDays: [String], intakeTimes: [String]) -> MedicineFrequency {
    let weekdays = intakeDays.compactMap { apiDay -> Weekday? in
        switch apiDay {
        case "MONDAY": return .monday
        case "TUESDAY": return .tuesday
        case "WEDNESDAY": return .wednesday
        case "THURSDAY": return .thursday
        case "FRIDAY": return .friday
        case "SATURDAY": return .saturday
        case "SUNDAY": return .sunday
        default: return nil
        }
    }

    let medicineTimes = intakeTimes.compactMap { timeString -> MedicineTime? in
        let components = timeString.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        return MedicineTime(hour: hour, minute: minute)
    }

    let frequencyType: MedicineFrequency.FrequencyType
    if weekdays.count == 7 {
        frequencyType = .daily
    } else {
        frequencyType = .weekly(weekdays)
    }

    return MedicineFrequency(type: frequencyType, times: medicineTimes)
}

private func convertAPIStatusToMedicineStatus(_ apiStatus: String) -> MedicineRoutine.MedicineStatus {
    switch apiStatus {
    case "PLANNED": return .beforeTaking
    case "TAKING": return .taking
    case "ENDED": return .completed
    default: return .taking
    }
}
