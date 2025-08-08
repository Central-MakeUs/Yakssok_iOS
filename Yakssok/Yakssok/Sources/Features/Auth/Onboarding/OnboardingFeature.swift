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
        case onboardingCompleted
        case onboardingFailed(String)
        case isCompleted(nickname: String, authorizationCode: String, oauthType: String, identityToken: String? = nil)
        case backToLogin
    }

    @Dependency(\.authAPIClient) var authAPIClient

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

                return .run { [nickname = state.nickname.trimmingCharacters(in: .whitespaces)] send in
                    do {
                        let request = UpdateNicknameRequest(nickName: nickname)
                        try await authAPIClient.updateNickname(request)
                        await send(.onboardingCompleted)
                    } catch {
                        await send(.onboardingFailed(error.localizedDescription))
                    }
                }

            case .onboardingCompleted:
                return .none

            case .onboardingFailed(let error):
                return .none

            case .backToLogin:
                return .none

            case .isCompleted:
                return .none
            }
        }
    }
}
