//
//  MockMedicineData.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

//import Foundation
//
//struct MockMedicineData {
//    enum DataType: CaseIterable {
//        case noRoutines
//        case noMedicineToday
//        case hasMedicines
//        case manyMedicines
//
//        var description: String {
//            switch self {
//            case .noRoutines:
//                return "루틴 없음"
//            case .noMedicineToday:
//                return "오늘 약 없음"
//            case .hasMedicines:
//                return "약 있음"
//            case .manyMedicines:
//                return "많은 약 (스크롤 테스트)"
//            }
//        }
//    }
//
//    static func medicineData(for type: DataType) -> MedicineDataResponse {
//        switch type {
//        case .noRoutines:
//            return MedicineDataResponse(
//                routines: emptyRoutines,
//                todayMedicines: emptyTodayMedicines,
//                completedMedicines: emptyCompletedMedicines
//            )
//        case .noMedicineToday:
//            return MedicineDataResponse(
//                routines: hasRoutinesButNoToday,
//                todayMedicines: noTodayMedicines,
//                completedMedicines: noTodayCompleted
//            )
//        case .hasMedicines:
//            return MedicineDataResponse(
//                routines: sampleRoutines,
//                todayMedicines: sampleTodayMedicines,
//                completedMedicines: sampleCompletedMedicines
//            )
//        case .manyMedicines:
//            return MedicineDataResponse(
//                routines: sampleRoutines,
//                todayMedicines: manyTodayMedicines,
//                completedMedicines: manyCompletedMedicines
//            )
//        }
//    }
//
//    /// 루틴 없는 경우
//    private static let emptyRoutines: [MedicineRoutine] = []
//    private static let emptyTodayMedicines: [Medicine] = []
//    private static let emptyCompletedMedicines: [Medicine] = []
//
//    /// 루틴은 있지만 오늘 먹을 약 없는 경우
//    private static let hasRoutinesButNoToday: [MedicineRoutine] = [
//        MedicineRoutine(id: "routine1", medicineName: "종합 비타민", schedule: ["8:00", "20:00"])
//    ]
//    private static let noTodayMedicines: [Medicine] = []
//    private static let noTodayCompleted: [Medicine] = []
//
//    /// 먹을 약과 완료된 약이 모두 있는 경우
//    private static let sampleRoutines: [MedicineRoutine] = [
//        MedicineRoutine(id: "routine1", medicineName: "종합 비타민 오쏘몰", schedule: ["9:00", "21:00"]),
//        MedicineRoutine(id: "routine2", medicineName: "오메가3", schedule: ["9:00"])
//    ]
//
//    private static let sampleTodayMedicines: [Medicine] = [
//        Medicine(
//            id: "medicine1",
//            name: "어메가",
//            dosage: "1정",
//            time: "9:00 am",
//            color: .purple
//        ),
//        Medicine(
//            id: "medicine4",
//            name: "오쏘몰",
//            dosage: "1정",
//            time: "9:00 am",
//            color: .yellow
//        ),
//        Medicine(
//            id: "medicine5",
//            name: "종합 비타민",
//            dosage: "1정",
//            time: "9:00 am",
//            color: .blue
//        )
//    ]
//
//    private static let sampleCompletedMedicines: [Medicine] = [
//        Medicine(
//            id: "medicine2",
//            name: "비타민C",
//            dosage: "1정",
//            time: "9:00 am",
//            color: .green
//        ),
//        Medicine(
//            id: "medicine3",
//            name: "젤리",
//            dosage: "1정",
//            time: "9:00 am",
//            color: .pink
//        )
//    ]
//
//    private static let manyTodayMedicines: [Medicine] = [
//        Medicine(id: "m1", name: "종합 비타민 오쏘몰", dosage: "1정", time: "9:00 am", color: .purple),
//        Medicine(id: "m2", name: "오메가3", dosage: "2정", time: "12:00 pm", color: .yellow),
//        Medicine(id: "m3", name: "마그네슘", dosage: "1정", time: "6:00 pm", color: .blue),
//        Medicine(id: "m4", name: "비타민D", dosage: "1정", time: "9:00 pm", color: .green),
//        Medicine(id: "m5", name: "프로바이오틱스", dosage: "1캡슐", time: "8:00 am", color: .purple),
//        Medicine(id: "m6", name: "철분제", dosage: "1정", time: "2:00 pm", color: .pink)
//    ]
//
//    private static let manyCompletedMedicines: [Medicine] = [
//        Medicine(id: "c1", name: "아침 종합비타민", dosage: "1정", time: "8:00 am", color: .green),
//        Medicine(id: "c2", name: "칼슘", dosage: "2정", time: "10:00 am", color: .blue),
//        Medicine(id: "c3", name: "루테인", dosage: "1정", time: "1:00 pm", color: .yellow)
//    ]
//}
