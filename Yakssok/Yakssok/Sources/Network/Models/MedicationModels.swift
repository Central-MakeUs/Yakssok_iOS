//
//  MedicationModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/27/25.
//

import Foundation

// MARK: - POST /api/medications Request
struct MedicationCreateRequest: Codable {
    let name: String
    let medicineType: String
    let startDate: String
    let endDate: String?
    let intakeDays: [String]
    let intakeCount: Int
    let alarmSound: String
    let intakeTimes: [String]
}

// MARK: - POST /api/medications Response
struct MedicationCreateResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
}

// MARK: - GET /api/medications Response
struct MedicationListResponse: Codable {
    let code: Int
    let message: String
    let body: MedicationListBody
}

struct MedicationListBody: Codable {
    let medicationCardResponses: [MedicationCardResponse]
}

struct MedicationCardResponse: Codable {
    let medicationType: String
    let medicineName: String
    let medicationStatus: String
    let intakeDays: [String]
    let intakeCount: Int
    let intakeTimes: [String]
}

// MARK: - GET /api/medication-schedules Response
struct MedicationScheduleResponse: Codable {
    let code: Int
    let message: String
    let body: MedicationScheduleBody
}

struct MedicationScheduleBody: Codable {
    let groupedSchedules: [String: [DaySchedule]]
}

struct DaySchedule: Codable {
    let date: String
    let allTaken: Bool
    let schedules: [MedicationSchedule]
}

struct MedicationSchedule: Codable {
    let date: String
    let scheduleId: Int?
    let medicationType: String
    let medicationName: String
    let intakeTime: String
    let isTaken: Bool
}

// MARK: - PUT /api/medication-schedules/{scheduleId}/take
struct TakeMedicationResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
}

// MARK: - PUT /api/medications/{medicationId}/end Response
struct StopMedicineResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
}

// MARK: - Common Models
struct EmptyBody: Codable {}

// MARK: - API Request Mapping Extensions
extension MedicineRegistrationData {
    func toAPIRequest() -> MedicationCreateRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let apiIntakeDays: [String]
        switch frequency.type {
        case .daily:
            apiIntakeDays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        case .weekly(let weekdays):
            apiIntakeDays = weekdays.map { $0.toAPIString() }
        }

        let apiIntakeTimes = frequency.times.map { medicineTime in
            String(format: "%02d:%02d:00", medicineTime.hour, medicineTime.minute)
        }

        return MedicationCreateRequest(
            name: medicineInfo.name,
            medicineType: category.toAPIString(),
            startDate: dateFormatter.string(from: dateRange.startDate),
            endDate: dateRange.startDate == dateRange.endDate ? nil : dateFormatter.string(from: dateRange.endDate),
            intakeDays: apiIntakeDays,
            intakeCount: frequency.times.count,
            alarmSound: alarmSound.toAPIString(),
            intakeTimes: apiIntakeTimes
        )
    }
}

extension MedicineCategory {
    func toAPIString() -> String {
        switch self.id {
        case "mental": return "MENTAL"
        case "beauty": return "BEAUTY"
        case "chronic": return "CHRONIC"
        case "diet": return "DIET"
        case "pain": return "TEMPORARY"
        case "supplement": return "SUPPLEMENT"
        case "other": return "OTHER"
        default: return "OTHER"
        }
    }
}

extension AlarmSound {
    func toAPIString() -> String {
        switch self.id {
        case "gentle": return "FEEL_GOOD"
        case "rhythm": return "PILL_SHAKE"
        case "nagging": return "SCOLD"
        case "electronic": return "CALL"
        case "vibration": return "VIBRATION"
        default: return "FEEL_GOOD"
        }
    }
}

extension Weekday {
    func toAPIString() -> String {
        switch self {
        case .monday: return "MONDAY"
        case .tuesday: return "TUESDAY"
        case .wednesday: return "WEDNESDAY"
        case .thursday: return "THURSDAY"
        case .friday: return "FRIDAY"
        case .saturday: return "SATURDAY"
        case .sunday: return "SUNDAY"
        }
    }

    static func fromCalendarWeekday(_ weekday: Int) -> Weekday {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

// MARK: - API Response to UI Model Conversion
extension MedicationCardResponse {
    func toMedicineDataResponse(for selectedDate: Date = Date()) -> (todayMedicines: [Medicine], completedMedicines: [Medicine]) {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate)

        let selectedWeekdayString = Weekday.fromCalendarWeekday(selectedWeekday).toAPIString()
        let shouldTakeOnSelectedDate = intakeDays.contains(selectedWeekdayString)

        guard shouldTakeOnSelectedDate else {
            return (todayMedicines: [], completedMedicines: [])
        }

        let medicines = intakeTimes.map { timeString in
            Medicine(
                id: UUID().uuidString,
                name: medicineName,
                dosage: nil,
                time: convertTimeToDisplayFormat(timeString),
                color: colorFromMedicationType(medicationType)
            )
        }

        return (todayMedicines: medicines, completedMedicines: [])
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
}


func colorFromMedicationCategory(_ colorType: MedicineCategory.CategoryColorType) -> MedicineColor {
    switch colorType {
    case .mental: return .purple
    case .beauty: return .green
    case .chronic: return .blue
    case .diet: return .pink
    case .pain: return .yellow
    case .supplement: return .orange
    case .other: return .red
    }
}

extension MedicationScheduleResponse {
    func toMedicineDataResponse() -> MedicineDataResponse {
        var allTodayMedicines: [Medicine] = []
        var allCompletedMedicines: [Medicine] = []

        for (_, daySchedules) in body.groupedSchedules {
            for daySchedule in daySchedules {
                for schedule in daySchedule.schedules {
                    let medicine = Medicine(
                        id: schedule.scheduleId?.description ?? "\(schedule.medicationName)-\(schedule.intakeTime)",
                        name: schedule.medicationName,
                        dosage: nil,
                        time: convertTimeToDisplayFormat(schedule.intakeTime),
                        color: colorFromMedicationType(schedule.medicationType)
                    )

                    if schedule.isTaken {
                        allCompletedMedicines.append(medicine)
                    } else {
                        allTodayMedicines.append(medicine)
                    }
                }
            }
        }

        return MedicineDataResponse(
            routines: [],
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
}

func colorFromMedicationType(_ medicationType: String) -> MedicineColor {
    let type = MedicineCategory.CategoryColorType(rawValue: medicationType.lowercased()) ?? .other
    return colorFromMedicationCategory(type)
}
