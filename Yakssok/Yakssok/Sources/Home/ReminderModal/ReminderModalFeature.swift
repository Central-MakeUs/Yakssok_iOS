//
//  ReminderModalFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture
import Foundation

struct ReminderModalFeature: Reducer {
    struct State: Equatable {
        let userName: String
        let missedMedicines: [Medicine]

        var shouldScroll: Bool {
            missedMedicines.count > 5
        }
    }

    @CasePathable
    enum Action: Equatable {
        case takeMedicineNowTapped
        case closeButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .takeMedicineNowTapped:
                // TODO: 홈 화면으로 이동
                return .none

            case .closeButtonTapped:
                return .none
            }
        }
    }
}
