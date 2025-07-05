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
    }

    @CasePathable
    enum Action: Equatable {
        case splash(SplashFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .splash(.isCompleted):
                state.splash = nil
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.splash, action: \.splash) {
            SplashFeature()
        }
    }
}
