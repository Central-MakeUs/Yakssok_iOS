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
        var isMasterModeEnabled: Bool = false
        var showMasterPasswordAlert: Bool = false
        var masterPassword: String = ""
    }

    enum Action: Equatable {
        case onAppear

        // 일반 로그인
        case kakaoLoginTapped
        case appleLoginTapped
        case kakaoLoginSuccess(result: KakaoLoginResult)
        case appleLoginSuccess(result: AppleLoginResult)
        case loginAPISuccess(accessToken: String, refreshToken: String, isInitialized: Bool)
        case loginAPIFailure(String)
        case authenticationCompleted(needsOnboarding: Bool)

        // 마스터 계정
        case logoLongPressed
        case masterLoginTapped
        case masterPasswordChanged(String)
        case masterLoginConfirmed
        case masterLoginCancelled
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

            // MARK: - 마스터 모드
            case .logoLongPressed:
                guard MasterAccountManager.isMasterModeAvailable else { return .none }
                state.isMasterModeEnabled = true
                return .none

            case .masterLoginTapped:
                state.showMasterPasswordAlert = true
                state.masterPassword = ""
                return .none

            case .masterPasswordChanged(let password):
                state.masterPassword = password
                return .none

            case .masterLoginCancelled:
                state.showMasterPasswordAlert = false
                state.isMasterModeEnabled = false
                state.masterPassword = ""
                return .none

            case .masterLoginConfirmed:
                guard state.masterPassword == MasterAccountManager.getMasterPassword() else {
                    state.masterPassword = ""
                    return .none
                }

                state.showMasterPasswordAlert = false
                state.isLoading = true

                return .run { send in
                    guard let credentials = MasterAccountManager.getMasterCredentials() else {
                        await send(.loginAPIFailure("마스터 계정 정보를 찾을 수 없습니다."))
                        return
                    }

                    tokenManager.saveTokens(credentials.accessToken, credentials.refreshToken)

                    await send(.loginAPISuccess(
                        accessToken: credentials.accessToken,
                        refreshToken: credentials.refreshToken,
                        isInitialized: true
                    ))
                }

            // MARK: - 일반 로그인
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
                            refreshToken: response.body.refreshToken,
                            isInitialized: response.body.isInitialized
                        ))
                    } catch {
                        await send(.loginAPIFailure(error.localizedDescription))
                    }
                }

            case .appleLoginSuccess(let result):
                return .run { send in
                    do {
                        let loginRequest = LoginRequest(
                            oauthAuthorizationCode: result.authorizationCode ?? result.identityToken,
                            oauthType: "apple",
                            nonce: result.nonce
                        )

                        let response = try await authAPIClient.login(loginRequest)

                        await send(.loginAPISuccess(
                            accessToken: response.body.accessToken,
                            refreshToken: response.body.refreshToken,
                            isInitialized: response.body.isInitialized
                        ))
                    } catch {
                        await send(.loginAPIFailure(error.localizedDescription))
                    }
                }

            case .loginAPISuccess(let accessToken, let refreshToken, let isInitialized):
                state.isLoading = false
                tokenManager.saveTokens(accessToken, refreshToken)
                return .send(.authenticationCompleted(needsOnboarding: !isInitialized))

            case .loginAPIFailure(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .authenticationCompleted:
                return .none
            }
        }
    }
}
