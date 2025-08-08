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
        var isLoading: Bool = false
        var error: String? = nil
    }

    @CasePathable
    enum Action: Equatable {
        case cancelTapped
        case withdrawalTapped
        case withdrawalAPI
        case withdrawalSuccess
        case withdrawalFailed(String)
        case withdrawalCompleteTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case dismissed
            case withdrawalCompleted
        }
    }

    @Dependency(\.authAPIClient) var authAPIClient
    @Dependency(\.tokenManager) var tokenManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelTapped:
                return .send(.delegate(.dismissed))

            case .withdrawalTapped:
                state.isLoading = true
                state.error = nil
                return .send(.withdrawalAPI)

            case .withdrawalAPI:
                return .run { send in
                    do {
                        try await authAPIClient.withdrawal()
                        await send(.withdrawalSuccess)
                    } catch {
                        await send(.withdrawalFailed(error.localizedDescription))
                    }
                }

            case .withdrawalSuccess:
                state.isLoading = false
                // 토큰 삭제
                tokenManager.clearTokens()
                state.showWithdrawalComplete = true
                return .none

            case .withdrawalFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .withdrawalCompleteTapped:
                return .send(.delegate(.withdrawalCompleted))

            case .delegate:
                return .none
            }
        }
    }
}
