//
//  AuthFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct AuthFeature: Reducer {
    struct State: Equatable {
        var login: LoginFeature.State? = .init()
        var onboarding: OnboardingFeature.State?
        var loading: LoadingFeature.State?
    }

    @CasePathable
    enum Action: Equatable {
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case loading(LoadingFeature.Action)
        case authenticationCompleted
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.isCompleted(let isExistingUser, let authorizationCode, let oauthType, let identityToken)):
                state.login = nil
                if isExistingUser {
                    return .send(.authenticationCompleted)
                } else {
                    var onboardingState = OnboardingFeature.State()
                    onboardingState.authorizationCode = authorizationCode ?? ""
                    onboardingState.oauthType = oauthType ?? "kakao"
                    onboardingState.identityToken = identityToken
                    state.onboarding = onboardingState
                    return .none
                }

            case .onboarding(.isCompleted(let nickname, let authorizationCode, let oauthType, let identityToken)):
                state.onboarding = nil
                state.loading = LoadingFeature.State(
                    nickname: nickname,
                    authorizationCode: authorizationCode,
                    oauthType: oauthType,
                    identityToken: identityToken
                )
                return .none

            case .loading(.registrationCompleted):
                state.loading = nil
                return .send(.authenticationCompleted)

            case .loading(.registrationFailed):
                state.loading = nil
                state.onboarding = .init()
                return .none

            case .onboarding(.backToLogin):
                state.onboarding = nil
                state.login = .init()
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .ifLet(\.loading, action: \.loading) {
            LoadingFeature()
        }
    }
}
