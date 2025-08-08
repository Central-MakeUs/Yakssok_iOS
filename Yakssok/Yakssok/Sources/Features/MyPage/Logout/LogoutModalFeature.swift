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
        var isLoading: Bool = false
        var error: String? = nil
    }

    @CasePathable
    enum Action: Equatable {
        case cancelTapped
        case logoutTapped
        case logoutAPI
        case logoutSuccess
        case logoutFailed(String)
        case logoutCompleteTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case dismissed
            case logoutCompleted
        }
    }

    @Dependency(\.authAPIClient) var authAPIClient
    @Dependency(\.tokenManager) var tokenManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelTapped:
                return .send(.delegate(.dismissed))

            case .logoutTapped:
                state.isLoading = true
                state.error = nil
                return .send(.logoutAPI)

            case .logoutAPI:
                return .run { send in
                    do {
                        try await authAPIClient.logout()
                        await send(.logoutSuccess)
                    } catch {
                        await send(.logoutFailed(error.localizedDescription))
                    }
                }

            case .logoutSuccess:
                state.isLoading = false
                // 토큰 삭제
                tokenManager.clearTokens()
                state.showLogoutComplete = true
                return .none

            case .logoutFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .logoutCompleteTapped:
                return .send(.delegate(.logoutCompleted))

            case .delegate:
                return .none
            }
        }
    }
}
