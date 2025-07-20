//
//  MedicineClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import ComposableArchitecture
import Foundation

struct MedicineClient {
    var loadMedicineData: () async throws -> MedicineDataResponse
    var loadMedicineDataForDate: (Date) async throws -> MedicineDataResponse
}

extension MedicineClient: DependencyKey {
    static let liveValue = Self(
        loadMedicineData: {
            // TODO: 실제 API 구현
            return MockCalendarData.medicineDataForDate(Date())
        },
        loadMedicineDataForDate: { date in
            // TODO: 실제 API 구현 (특정 날짜)
            return MockCalendarData.medicineDataForDate(date)
        }
    )

#if DEBUG
    static let previewValue = Self(
        loadMedicineData: {
            return MockCalendarData.medicineDataForDate(Date())
        },
        loadMedicineDataForDate: { date in
            return MockCalendarData.medicineDataForDate(date)
        }
    )

    static let testValue = Self(
        loadMedicineData: {
            return MockMedicineData.medicineData(for: .noRoutines)
        },
        loadMedicineDataForDate: { date in
            return MockCalendarData.medicineDataForDate(date)
        }
    )
#endif
}

extension DependencyValues {
    var medicineClient: MedicineClient {
        get { self[MedicineClient.self] }
        set { self[MedicineClient.self] = newValue }
    }
}
