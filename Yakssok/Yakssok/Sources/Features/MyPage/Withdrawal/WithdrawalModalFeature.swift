//
//  WithdrawalModalFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import ComposableArchitecture
import Foundation

struct WithdrawalModalFeature: Reducer {
    struct State: Equatable {
        var showWithdrawalComplete: Bool = false
    }

    @CasePathable
    enum Action: Equatable {
        case cancelTapped
        case withdrawalTapped
        case withdrawalCompleteTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case dismissed
            case withdrawalCompleted
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelTapped:
                return .send(.delegate(.dismissed))

            case .withdrawalTapped:
                state.showWithdrawalComplete = true
                return .none
                
            case .withdrawalCompleteTapped:
                return .send(.delegate(.withdrawalCompleted))

            case .delegate:
                return .none
            }
        }
    }
}
