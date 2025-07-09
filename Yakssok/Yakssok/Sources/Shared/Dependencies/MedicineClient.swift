//
//  MedicineClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import ComposableArchitecture

struct MedicineClient {
    var loadMedicineData: () async throws -> MedicineDataResponse
}

extension MedicineClient: DependencyKey {
    static let liveValue = Self(
        loadMedicineData: {
            // TODO: 실제 API 구현
            // 테스트: 3가지 상태 중 하나 선택해서 테스트: noRoutines, noMedicineToday, hasMedicines, manyMedicines
            return MockMedicineData.medicineData(for: .hasMedicines)
        }
    )

    #if DEBUG
    static let previewValue = Self(
        loadMedicineData: {
            return MockMedicineData.medicineData(for: .hasMedicines)
        }
    )

    static let testValue = Self(
        loadMedicineData: {
            return MockMedicineData.medicineData(for: .noRoutines)
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
