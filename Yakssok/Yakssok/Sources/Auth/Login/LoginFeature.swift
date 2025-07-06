//
//  LoginFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct LoginFeature: Reducer {
    struct State: Equatable {
    }

    enum Action: Equatable {
        case onAppear
        case kakaoLoginTapped
        case appleLoginTapped
        case isCompleted(isExistingUser: Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .kakaoLoginTapped:
                return .send(.isCompleted(isExistingUser: false))
            case .appleLoginTapped:
                return .send(.isCompleted(isExistingUser: true))
            case .isCompleted:
                return .none
            }
        }
    }
}
