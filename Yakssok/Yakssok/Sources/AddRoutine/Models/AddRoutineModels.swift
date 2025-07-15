//
//  AddRoutineModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import Foundation

struct DateRange: Equatable {
    let startDate: Date
    let endDate: Date
}

struct MedicineFrequency: Equatable {
    let type: FrequencyType
    let times: [MedicineTime]

    enum FrequencyType: Equatable {
        case daily
        case weekly([Weekday])
    }
}

struct MedicineTime: Equatable {
    let hour: Int
    let minute: Int

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        return formatter.string(from: date)
    }

    var displayTimeString: String {
        let period = hour < 12 ? "오전" : "오후"
        let displayHour = hour <= 12 ? hour : hour - 12
        let finalHour = displayHour == 0 ? 12 : displayHour
        return String(format: "%@ %d:%02d", period, finalHour, minute)
    }
}

enum Weekday: Int, CaseIterable, Equatable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortName: String {
        switch self {
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        case .sunday: return "일"
        }
    }
}

struct AlarmSound: Equatable {
    let id: String
    let name: String
    let fileName: String
}

struct MedicineInfo: Equatable {
    let name: String
    let dosage: String?
    let color: MedicineColor
}

struct MedicineRegistrationData: Equatable {
    let category: MedicineCategory
    let dateRange: DateRange
    let frequency: MedicineFrequency
    let alarmSound: AlarmSound
    let medicineInfo: MedicineInfo

    func toMedicineRoutine() -> MedicineRoutine {
        let timeStrings = frequency.times.map { $0.timeString }
        return MedicineRoutine(
            id: UUID().uuidString,
            medicineName: medicineInfo.name,
            schedule: timeStrings
        )
    }
}
