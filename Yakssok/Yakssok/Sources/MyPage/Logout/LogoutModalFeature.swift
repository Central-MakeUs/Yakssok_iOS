//
//  LogoutModalFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import ComposableArchitecture
import Foundation

struct LogoutModalFeature: Reducer {
    struct State: Equatable {
        var showLogoutComplete: Bool = false
    }

    @CasePathable
    enum Action: Equatable {
        case cancelTapped
        case logoutTapped
        case logoutCompleteTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case dismissed
            case logoutCompleted
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelTapped:
                return .send(.delegate(.dismissed))

            case .logoutTapped:
                state.showLogoutComplete = true
                return .none

            case .logoutCompleteTapped:
                return .send(.delegate(.logoutCompleted))

            case .delegate:
                return .none
            }
        }
    }
}
