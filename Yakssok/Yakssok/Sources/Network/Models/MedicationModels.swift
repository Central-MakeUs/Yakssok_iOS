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

// MARK: - Common Models
struct EmptyBody: Codable {}

// MARK: - API Request Mapping Extensions
extension MedicineRegistrationData {
    func toAPIRequest() -> MedicationCreateRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // 요일 매핑
        let apiIntakeDays: [String]
        switch frequency.type {
        case .daily:
            apiIntakeDays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        case .weekly(let weekdays):
            apiIntakeDays = weekdays.map { $0.toAPIString() }
        }

        // 시간 매핑 (HH:mm:ss 형식)
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
}

// MARK: - API Response을 UI Model로 변환
extension MedicationCardResponse {
    func toMedicineDataResponse(for selectedDate: Date = Date()) -> (todayMedicines: [Medicine], completedMedicines: [Medicine]) {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate)

        // 선택된 날짜의 요일이 복용 요일에 포함되는지 확인
        let selectedWeekdayString = Weekday.fromCalendarWeekday(selectedWeekday).toAPIString()
        let shouldTakeOnSelectedDate = intakeDays.contains(selectedWeekdayString)

        guard shouldTakeOnSelectedDate else {
            return (todayMedicines: [], completedMedicines: [])
        }

        // 시간별로 Medicine 객체 생성
        let medicines = intakeTimes.map { timeString in
            Medicine(
                id: UUID().uuidString,
                name: medicineName,
                dosage: nil,
                time: convertTimeToDisplayFormat(timeString),
                color: .purple
            )
        }

        // 복용 상태에 따라 분류 (임시로 모두 todayMedicines에 배치)
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

extension Weekday {
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
