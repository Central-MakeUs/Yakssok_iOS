//
//  FullCalendarMedicineClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/24/25.
//

import ComposableArchitecture
import Foundation

struct FullCalendarMedicineClient {
    var loadMedicineDataForDate: (Date) async throws -> MedicineDataResponse
}

extension FullCalendarMedicineClient: DependencyKey {
    static let liveValue = Self(
        loadMedicineDataForDate: { date in
            return MockCalendarData.medicineDataForDate(date)
        }
    )
}

extension DependencyValues {
    var fullCalendarMedicineClient: FullCalendarMedicineClient {
        get { self[FullCalendarMedicineClient.self] }
        set { self[FullCalendarMedicineClient.self] = newValue }
    }
}
