//
//  MockCalendarData.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import Foundation

struct MockCalendarData {

    struct APIResponse: Codable {
        let code: Int
        let message: String
        let body: APIBody
    }

    struct APIBody: Codable {
        let groupedSchedules: [String: [Schedule]]
    }

    struct Schedule: Codable {
        let date: String
        let scheduleId: Int
        let medicationType: String
        let medicationName: String
        let intakeTime: String
        let isTaken: Bool
    }

    static let mockAPIResponse = APIResponse(
        code: 0,
        message: "성공적으로 처리되었습니다.",
        body: APIBody(groupedSchedules: [
            "2025-06-10": [
                Schedule(date: "2025-06-10", scheduleId: 100, medicationType: "SUPPLEMENT", medicationName: "비타민C", intakeTime: "08:00:00", isTaken: true),
                Schedule(date: "2025-06-10", scheduleId: 101, medicationType: "CHRONIC", medicationName: "고혈압약", intakeTime: "20:00:00", isTaken: false)
            ],
            "2025-06-15": [
                Schedule(date: "2025-06-15", scheduleId: 102, medicationType: "BEAUTY", medicationName: "피부영양제", intakeTime: "10:00:00", isTaken: true),
                Schedule(date: "2025-06-15", scheduleId: 103, medicationType: "MENTAL", medicationName: "스트레스완화제", intakeTime: "22:00:00", isTaken: true)
            ],
            "2025-06-30": [
                Schedule(date: "2025-06-30", scheduleId: 104, medicationType: "SUPPLEMENT", medicationName: "철분제", intakeTime: "09:00:00", isTaken: false),
                Schedule(date: "2025-06-30", scheduleId: 105, medicationType: "DIET", medicationName: "다이어트보조제", intakeTime: "21:00:00", isTaken: false)
            ],
            "2025-07-01": [
                Schedule(date: "2025-07-01", scheduleId: 1, medicationType: "SUPPLEMENT", medicationName: "종합비타민", intakeTime: "09:00:00", isTaken: true),
                Schedule(date: "2025-07-01", scheduleId: 2, medicationType: "SUPPLEMENT", medicationName: "종합비타민", intakeTime: "21:00:00", isTaken: true),
                Schedule(date: "2025-07-01", scheduleId: 3, medicationType: "SUPPLEMENT", medicationName: "오메가3", intakeTime: "12:00:00", isTaken: true)
            ],
            "2025-07-02": [
                Schedule(date: "2025-07-02", scheduleId: 4, medicationType: "TEMPORARY", medicationName: "타이레놀", intakeTime: "09:00:00", isTaken: true),
                Schedule(date: "2025-07-02", scheduleId: 5, medicationType: "TEMPORARY", medicationName: "타이레놀", intakeTime: "14:00:00", isTaken: false),
                Schedule(date: "2025-07-02", scheduleId: 6, medicationType: "TEMPORARY", medicationName: "타이레놀", intakeTime: "21:00:00", isTaken: false),
                Schedule(date: "2025-07-02", scheduleId: 7, medicationType: "SUPPLEMENT", medicationName: "마그네슘", intakeTime: "18:00:00", isTaken: false)
            ],
            "2025-07-03": [
                Schedule(date: "2025-07-03", scheduleId: 20, medicationType: "SUPPLEMENT", medicationName: "루테인", intakeTime: "09:00:00", isTaken: false),
                Schedule(date: "2025-07-03", scheduleId: 21, medicationType: "SUPPLEMENT", medicationName: "루테인", intakeTime: "21:00:00", isTaken: true)
            ],
            "2025-07-04": [
                Schedule(date: "2025-07-04", scheduleId: 22, medicationType: "CHRONIC", medicationName: "당뇨약", intakeTime: "08:00:00", isTaken: true),
                Schedule(date: "2025-07-04", scheduleId: 23, medicationType: "CHRONIC", medicationName: "당뇨약", intakeTime: "20:00:00", isTaken: true)
            ],
            "2025-07-05": [
                Schedule(date: "2025-07-05", scheduleId: 24, medicationType: "TEMPORARY", medicationName: "두통약", intakeTime: "14:00:00", isTaken: false)
            ],
            "2025-07-06": [], // 루틴 없는 날
            "2025-07-07": [
                Schedule(date: "2025-07-07", scheduleId: 25, medicationType: "SUPPLEMENT", medicationName: "비타민C", intakeTime: "08:00:00", isTaken: true)
            ],
            "2025-07-08": [
                Schedule(date: "2025-07-08", scheduleId: 26, medicationType: "MENTAL", medicationName: "항불안제", intakeTime: "09:00:00", isTaken: false),
                Schedule(date: "2025-07-08", scheduleId: 27, medicationType: "MENTAL", medicationName: "항불안제", intakeTime: "21:00:00", isTaken: false)
            ],
            "2025-07-09": [],
            "2025-07-10": [
                Schedule(date: "2025-07-10", scheduleId: 28, medicationType: "DIET", medicationName: "다이어트약", intakeTime: "07:00:00", isTaken: true),
                Schedule(date: "2025-07-10", scheduleId: 29, medicationType: "DIET", medicationName: "다이어트약", intakeTime: "19:00:00", isTaken: true)
            ],
            "2025-07-11": [
                Schedule(date: "2025-07-11", scheduleId: 30, medicationType: "HIGHRISK", medicationName: "면역억제제", intakeTime: "08:30:00", isTaken: false)
            ],
            "2025-07-12": [
                Schedule(date: "2025-07-12", scheduleId: 31, medicationType: "SUPPLEMENT", medicationName: "비오틴", intakeTime: "10:00:00", isTaken: false)
            ],
            "2025-07-13": [], // 루틴 없음
            "2025-07-14": [
                Schedule(date: "2025-07-14", scheduleId: 32, medicationType: "CHRONIC", medicationName: "고지혈증약", intakeTime: "08:00:00", isTaken: true),
                Schedule(date: "2025-07-14", scheduleId: 33, medicationType: "CHRONIC", medicationName: "고지혈증약", intakeTime: "20:00:00", isTaken: false)
            ],
            "2025-07-15": [
                Schedule(date: "2025-07-15", scheduleId: 34, medicationType: "SUPPLEMENT", medicationName: "칼슘", intakeTime: "09:00:00", isTaken: true),
                Schedule(date: "2025-07-15", scheduleId: 35, medicationType: "SUPPLEMENT", medicationName: "마그네슘", intakeTime: "21:00:00", isTaken: false)
            ],
            "2025-07-16": [
                Schedule(date: "2025-07-16", scheduleId: 36, medicationType: "SUPPLEMENT", medicationName: "비타민D", intakeTime: "12:00:00", isTaken: true)
            ],
            "2025-07-17": [], // 루틴 없음
            "2025-07-21": [
                Schedule(date: "2025-07-21", scheduleId: 10, medicationType: "SUPPLEMENT", medicationName: "어메가", intakeTime: "09:00:00", isTaken: false),
                Schedule(date: "2025-07-21", scheduleId: 11, medicationType: "SUPPLEMENT", medicationName: "어메가", intakeTime: "21:00:00", isTaken: false),
                Schedule(date: "2025-07-21", scheduleId: 12, medicationType: "BEAUTY", medicationName: "오쏘몰", intakeTime: "12:00:00", isTaken: false),
                Schedule(date: "2025-07-21", scheduleId: 13, medicationType: "CHRONIC", medicationName: "혈압약", intakeTime: "08:00:00", isTaken: true)
            ],
            "2025-07-22": [], // 루틴 없는 날
            "2025-07-23": [
                Schedule(date: "2025-07-23", scheduleId: 14, medicationType: "MENTAL", medicationName: "마그네슘", intakeTime: "09:00:00", isTaken: false),
                Schedule(date: "2025-07-23", scheduleId: 15, medicationType: "DIET", medicationName: "다이어트약", intakeTime: "21:00:00", isTaken: false),
                Schedule(date: "2025-07-23", scheduleId: 16, medicationType: "SUPPLEMENT", medicationName: "오메가3", intakeTime: "12:00:00", isTaken: false)
            ],
            "2025-07-24": [
                Schedule(date: "2025-07-24", scheduleId: 17, medicationType: "HIGHRISK", medicationName: "항암제", intakeTime: "09:00:00", isTaken: true),
                Schedule(date: "2025-07-24", scheduleId: 18, medicationType: "CHRONIC", medicationName: "당뇨약", intakeTime: "21:00:00", isTaken: true),
                Schedule(date: "2025-07-24", scheduleId: 19, medicationType: "SUPPLEMENT", medicationName: "칼슘", intakeTime: "14:00:00", isTaken: true)
            ],
            "2025-07-25": [], // 오늘 약 없는 날
            "2025-08-01": [
                Schedule(date: "2025-08-01", scheduleId: 200, medicationType: "SUPPLEMENT", medicationName: "비타민D", intakeTime: "08:00:00", isTaken: true),
                Schedule(date: "2025-08-01", scheduleId: 201, medicationType: "TEMPORARY", medicationName: "감기약", intakeTime: "14:00:00", isTaken: false),
                Schedule(date: "2025-08-01", scheduleId: 202, medicationType: "SUPPLEMENT", medicationName: "루테인", intakeTime: "21:00:00", isTaken: false)
            ],
            "2025-08-10": [
                Schedule(date: "2025-08-10", scheduleId: 203, medicationType: "CHRONIC", medicationName: "고지혈증약", intakeTime: "07:00:00", isTaken: true)
            ],
            "2025-08-20": [
                Schedule(date: "2025-08-20", scheduleId: 204, medicationType: "BEAUTY", medicationName: "헤어영양제", intakeTime: "11:00:00", isTaken: false),
                Schedule(date: "2025-08-20", scheduleId: 205, medicationType: "SUPPLEMENT", medicationName: "칼슘제", intakeTime: "21:00:00", isTaken: true)
            ]
        ])
    )

    static func medicineDataForDate(_ date: Date) -> MedicineDataResponse {
        let dateKey = formatDate(date)
        let schedules = mockAPIResponse.body.groupedSchedules[dateKey] ?? []

        if schedules.isEmpty {
            // 스케줄이 없는 경우
            let hasAnyRoutines = !mockAPIResponse.body.groupedSchedules.isEmpty

            if hasAnyRoutines {
                // 다른 날짜에는 루틴이 있지만 오늘만 없음
                return MedicineDataResponse(
                    routines: [MedicineRoutine(id: "default", medicineName: "기본 루틴", schedule: ["9:00"])],
                    todayMedicines: [],
                    completedMedicines: []
                )
            } else {
                // 완전히 루틴이 없는 사용자
                return MedicineDataResponse(
                    routines: [],
                    todayMedicines: [],
                    completedMedicines: []
                )
            }
        }

        let todayMedicines = schedules.filter { !$0.isTaken }.map { schedule in
            Medicine(
                id: "\(schedule.scheduleId)",
                name: schedule.medicationName,
                dosage: "1정",
                time: formatTime(schedule.intakeTime),
                color: getMedicineColor(for: schedule.medicationType)
            )
        }

        let completedMedicines = schedules.filter { $0.isTaken }.map { schedule in
            Medicine(
                id: "\(schedule.scheduleId)",
                name: schedule.medicationName,
                dosage: "1정",
                time: formatTime(schedule.intakeTime),
                color: getMedicineColor(for: schedule.medicationType)
            )
        }

        let uniqueMedicineNames = Set(schedules.map { $0.medicationName })
        let routines = uniqueMedicineNames.map { medicineName in
            let times = schedules.filter { $0.medicationName == medicineName }
                .map { formatTime($0.intakeTime) }
            return MedicineRoutine(
                id: medicineName,
                medicineName: medicineName,
                schedule: times
            )
        }

        return MedicineDataResponse(
            routines: routines,
            todayMedicines: todayMedicines,
            completedMedicines: completedMedicines
        )
    }

    static var monthlyStatus: [String: MedicineStatus] {
        var status: [String: MedicineStatus] = [:]

        for (dateKey, schedules) in mockAPIResponse.body.groupedSchedules {
            if schedules.isEmpty {
                status[dateKey] = Optional.none
            } else {
                let notTakenCount = schedules.filter { !$0.isTaken }.count
                let takenCount = schedules.filter { $0.isTaken }.count

                if notTakenCount == 0 && takenCount > 0 {
                    status[dateKey] = .completed
                } else if notTakenCount > 0 {
                    status[dateKey] = .incomplete
                } else {
                    status[dateKey] = Optional.none
                }
            }
        }

        return status
    }

    // MARK: - Helper Methods
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        if let time = formatter.date(from: timeString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: time)
        }

        return timeString
    }

    private static func getMedicineColor(for medicationType: String) -> MedicineColor {
        // medicationType에 따라 색상 매핑
        switch medicationType {
        case "MENTAL":
            return .purple
        case "BEAUTY":
            return .green
        case "CHRONIC":
            return .blue
        case "DIET":
            return .pink
        case "TEMPORARY":
            return .yellow
        case "SUPPLEMENT":
            return .purple
        case "HIGHRISK":
            return .pink
        case "OTHER":
            return .purple
        default:
            return .purple
        }
    }
}
