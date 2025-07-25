//
//  LoginFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct LoginFeature: Reducer {
    struct State: Equatable {
        var isLoading: Bool = false
        var error: String?
    }

    enum Action: Equatable {
        case onAppear
        case kakaoLoginTapped
        case appleLoginTapped
        case kakaoLoginSuccess(authorizationCode: String)
        case loginAPISuccess(accessToken: String, refreshToken: String)
        case loginAPIFailure(String)
        case userNotFound(authorizationCode: String)
        case isCompleted(isExistingUser: Bool, authorizationCode: String? = nil)
    }

    @Dependency(\.kakaoAuthClient) var kakaoAuthClient
    @Dependency(\.authAPIClient) var authAPIClient
    @Dependency(\.tokenManager) var tokenManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .kakaoLoginTapped:
                state.isLoading = true
                state.error = nil
                tokenManager.clearTokens()

                return .run { send in
                    do {
                        let authorizationCode = try await kakaoAuthClient.login()
                        await send(.kakaoLoginSuccess(authorizationCode: authorizationCode))
                    } catch {
                        await send(.loginAPIFailure(error.localizedDescription))
                    }
                }

            case .appleLoginTapped:
                // TODO: 애플 로그인 구현
                return .send(.isCompleted(isExistingUser: true))

            case .kakaoLoginSuccess(let authorizationCode):
                return .run { send in
                    do {
                        let loginRequest = LoginRequest(
                            oauthAuthorizationCode: authorizationCode,
                            oauthType: "kakao"
                        )
                        let response = try await authAPIClient.login(loginRequest)

                        await send(.loginAPISuccess(
                            accessToken: response.body.accessToken,
                            refreshToken: response.body.refreshToken
                        ))
                    } catch {
                        if let apiError = error as? APIError,
                           case .userNotFound = apiError {
                            await send(.userNotFound(authorizationCode: authorizationCode))
                        } else {
                            await send(.loginAPIFailure(error.localizedDescription))
                        }
                    }
                }

            case .loginAPISuccess(let accessToken, let refreshToken):
                state.isLoading = false
                tokenManager.saveTokens(accessToken, refreshToken)
                return .send(.isCompleted(isExistingUser: true))

            case .userNotFound(let authorizationCode):
                state.isLoading = false
                return .send(.isCompleted(isExistingUser: false, authorizationCode: authorizationCode))

            case .loginAPIFailure(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .isCompleted:
                return .none
            }
        }
    }
}
