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
    }

    @CasePathable
    enum Action: Equatable {
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case authenticationCompleted
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.isCompleted(let isExistingUser)):
                state.login = nil
                if isExistingUser {
                    return .send(.authenticationCompleted)
                } else {
                    state.onboarding = .init()
                    return .none
                }
            case .onboarding(.isCompleted):
                state.onboarding = nil
                return .send(.authenticationCompleted)
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
    }
}
