//
//  OnboardingFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct OnboardingFeature: Reducer {
    struct State: Equatable {
        var nickname: String = ""

        var isButtonEnabled: Bool {
            !nickname.trimmingCharacters(in: .whitespaces).isEmpty && nickname.count <= 5
        }
    }

    enum Action: Equatable {
        case onAppear
        case nicknameChanged(String)
        case startButtonTapped
        case isCompleted(nickname: String)
        case backToLogin
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .nicknameChanged(let nickname):
                if nickname.count <= 5 {
                    state.nickname = nickname
                }
                return .none
            case .startButtonTapped:
                guard state.isButtonEnabled else { return .none }
                return .send(.isCompleted(nickname: state.nickname))
            case .backToLogin:
                return .none
            case .isCompleted:
                return .none
            }
        }
    }
}
