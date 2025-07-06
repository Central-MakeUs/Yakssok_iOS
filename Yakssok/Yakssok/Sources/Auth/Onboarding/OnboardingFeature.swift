//
//  OnboardingFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct OnboardingFeature: Reducer {
    struct State: Equatable {
    }

    enum Action: Equatable {
        case isCompleted
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .isCompleted:
                return .none
            }
        }
    }
}
