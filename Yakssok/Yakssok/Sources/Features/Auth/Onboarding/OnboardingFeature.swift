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
        var authorizationCode: String = ""
        var oauthType: String = ""
        var identityToken: String? // Apple 로그인용

        var isButtonEnabled: Bool {
            !nickname.trimmingCharacters(in: .whitespaces).isEmpty && nickname.count <= 5
        }
    }

    enum Action: Equatable {
        case onAppear
        case nicknameChanged(String)
        case startButtonTapped
        case isCompleted(nickname: String, authorizationCode: String, oauthType: String)
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
                return .send(.isCompleted(
                    nickname: state.nickname,
                    authorizationCode: state.authorizationCode,
                    oauthType: state.oauthType
                ))
                
            case .backToLogin:
                return .none

            case .isCompleted:
                return .none
            }
        }
    }
}
