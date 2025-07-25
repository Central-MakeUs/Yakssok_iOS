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
        case kakaoLoginSuccess(result: KakaoLoginResult)
        case appleLoginSuccess(result: AppleLoginResult)
        case loginAPISuccess(accessToken: String, refreshToken: String)
        case loginAPIFailure(String)
        case userNotFound(authorizationCode: String, oauthType: String)
        case isCompleted(isExistingUser: Bool, authorizationCode: String? = nil, oauthType: String? = nil)
    }

    @Dependency(\.kakaoAuthClient) var kakaoAuthClient
    @Dependency(\.appleAuthClient) var appleAuthClient
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
                        let result = try await kakaoAuthClient.login()
                        await send(.kakaoLoginSuccess(result: result))
                    } catch {
                        await send(.loginAPIFailure(error.localizedDescription))
                    }
                }

            case .appleLoginTapped:
                state.isLoading = true
                state.error = nil
                tokenManager.clearTokens()

                return .run { send in
                    do {
                        let result = try await appleAuthClient.login()
                        await send(.appleLoginSuccess(result: result))
                    } catch {
                        await send(.loginAPIFailure(error.localizedDescription))
                    }
                }

            case .kakaoLoginSuccess(let result):
                return .run { send in
                    do {
                        let loginRequest = LoginRequest(
                            oauthAuthorizationCode: result.authorizationCode,
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
                            await send(.userNotFound(
                                authorizationCode: result.authorizationCode,
                                oauthType: "kakao"
                            ))
                        } else {
                            await send(.loginAPIFailure(error.localizedDescription))
                        }
                    }
                }

            case .appleLoginSuccess(let result):
                return .run { send in
                    do {
                        let loginRequest = LoginRequest(
                            oauthAuthorizationCode: result.identityToken,
                            oauthType: "apple",
                            nonce: nil
                        )
                        let response = try await authAPIClient.login(loginRequest)

                        await send(.loginAPISuccess(
                            accessToken: response.body.accessToken,
                            refreshToken: response.body.refreshToken
                        ))
                    } catch {
                        if let apiError = error as? APIError,
                           case .userNotFound = apiError {
                            await send(.userNotFound(
                                authorizationCode: result.identityToken,
                                oauthType: "apple"
                            ))
                        } else {
                            await send(.loginAPIFailure(error.localizedDescription))
                        }
                    }
                }

            case .loginAPISuccess(let accessToken, let refreshToken):
                state.isLoading = false
                tokenManager.saveTokens(accessToken, refreshToken)
                return .send(.isCompleted(isExistingUser: true))

            case .userNotFound(let authorizationCode, let oauthType):
                state.isLoading = false
                return .send(.isCompleted(
                    isExistingUser: false,
                    authorizationCode: authorizationCode,
                    oauthType: oauthType
                ))

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
