//
//  MedicineClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import ComposableArchitecture
import Dependencies
import Foundation

struct MedicineClient {
    var loadMedicineData: () async throws -> MedicineDataResponse
    var createMedicineRoutine: (MedicineRegistrationData) async throws -> Void
}

extension MedicineClient: DependencyKey {
    static let liveValue = Self(
        loadMedicineData: {
            do {
                let response: MedicationListResponse = try await APIClient.shared.request(
                    endpoint: .getMedications,
                    method: .GET,
                    body: Optional<String>.none
                )

                if response.code != 0 {
                    throw APIError.serverError(response.code)
                }

                return convertToMedicineDataResponse(response)
            } catch {
                print("API 호출 실패: \(error)")
                return MedicineDataResponse(
                    routines: [],
                    todayMedicines: [],
                    completedMedicines: []
                )
            }
        },

        createMedicineRoutine: { registrationData in
            let request = registrationData.toAPIRequest()

            let response: MedicationCreateResponse = try await APIClient.shared.request(
                endpoint: .createMedication,
                method: .POST,
                body: request
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }
        }
    )
}

extension DependencyValues {
    var medicineClient: MedicineClient {
        get { self[MedicineClient.self] }
        set { self[MedicineClient.self] = newValue }
    }
}

// MARK: - Data 변환
private func convertToMedicineDataResponse(_ apiResponse: MedicationListResponse, selectedDate: Date = Date()) -> MedicineDataResponse {
    var allTodayMedicines: [Medicine] = []
    var allCompletedMedicines: [Medicine] = []
    var routines: [MedicineRoutine] = []

    for medicationCard in apiResponse.body.medicationCardResponses {
        // Medicine 객체 변환 (선택된 날짜 기준)
        let (todayMedicines, completedMedicines) = medicationCard.toMedicineDataResponse(for: selectedDate)
        allTodayMedicines.append(contentsOf: todayMedicines)
        allCompletedMedicines.append(contentsOf: completedMedicines)

        // MedicineRoutine 객체 생성
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

// MARK: - Helpers
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
