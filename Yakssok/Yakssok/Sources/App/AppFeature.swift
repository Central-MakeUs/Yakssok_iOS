//
//  AppFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/3/25.
//

import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        var splash: SplashFeature.State? = .init()
        var auth: AuthFeature.State?
        var home: HomeFeature.State?
    }

    @CasePathable
    enum Action: Equatable {
        case splash(SplashFeature.Action)
        case auth(AuthFeature.Action)
        case home(HomeFeature.Action)
        case tokenExpired
    }

    @Dependency(\.tokenManager) var tokenManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .splash(.isCompleted):
                state.splash = nil
                state.auth = .init()
                return .none
            case .auth(.authenticationCompleted):
                state.auth = nil
                state.home = .init()
                return .none
            case .home(.delegate(.logoutCompleted)),
                 .home(.delegate(.withdrawalCompleted)):
                state.home = nil
                state.auth = .init()
                return .none
            case .tokenExpired:
                tokenManager.clearTokens()
                state.home = nil
                state.auth = .init()
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.splash, action: \.splash) {
            SplashFeature()
        }
        .ifLet(\.auth, action: \.auth) {
            AuthFeature()
        }
        .ifLet(\.home, action: \.home) {
            HomeFeature()
        }
    }
}
