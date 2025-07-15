//
//  AlarmSelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture

struct AlarmSelectionFeature: Reducer {
    struct State: Equatable {
        var isNextButtonEnabled: Bool = true
    }

    enum Action: Equatable {
        case nextButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                return .none
            }
        }
    }
}
