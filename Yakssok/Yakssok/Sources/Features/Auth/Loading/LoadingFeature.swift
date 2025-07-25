//
//  LoadingFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import ComposableArchitecture
import Foundation

struct LoadingFeature: Reducer {
    struct State: Equatable {
        var currentIconIndex: Int = 0
        var nickname: String
        var authorizationCode: String
        var oauthType: String = ""
        var identityToken: String? // Apple 로그인용
        var isRegistering: Bool = false

        var currentIconName: String {
            return "loading-\(currentIconIndex + 1)"
        }

        init(nickname: String, authorizationCode: String, oauthType: String = "kakao", identityToken: String? = nil) {
            self.nickname = nickname
            self.authorizationCode = authorizationCode
            self.oauthType = oauthType
            self.identityToken = identityToken
        }
    }

    enum Action: Equatable {
        case onAppear
        case timerTicked
        case registrationCompleted
        case registrationFailed(String)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.authAPIClient) var authAPIClient
    @Dependency(\.tokenManager) var tokenManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isRegistering else { return .none }
                state.isRegistering = true

                guard !state.authorizationCode.isEmpty else {
                    return .send(.registrationFailed("Authorization Code가 없습니다."))
                }

                return .merge(
                    // 아이콘 애니메이션
                    .run { send in
                        for await _ in clock.timer(interval: .milliseconds(500)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: "iconTimer"),

                    // 회원가입 API 호출
                    .run { [nickname = state.nickname, authCode = state.authorizationCode, oauthType = state.oauthType, identityToken = state.identityToken] send in
                        do {
                            guard !authCode.isEmpty else {
                                throw APIError.invalidResponse
                            }

                            let joinRequest = JoinRequest(
                                oauthAuthorizationCode: authCode,
                                oauthType: oauthType,
                                nonce: identityToken,
                                nickName: nickname
                            )

                            // 1. 회원가입 API 호출
                            try await authAPIClient.join(joinRequest)

                            // 2. 회원가입 성공 후 바로 로그인
                            let loginRequest = LoginRequest(
                                oauthAuthorizationCode: authCode,
                                oauthType: oauthType,
                                nonce: identityToken
                            )
                            let loginResponse = try await authAPIClient.login(loginRequest)

                            // 3. 토큰 저장
                            tokenManager.saveTokens(
                                loginResponse.body.accessToken,
                                loginResponse.body.refreshToken
                            )

                            // 4. 로딩 애니메이션 시간 확보
                            try await clock.sleep(for: .seconds(2))

                            await send(.registrationCompleted)

                        } catch {
                            await send(.registrationFailed(error.localizedDescription))
                        }
                    }
                    .cancellable(id: "registration")
                )

            case .timerTicked:
                state.currentIconIndex = (state.currentIconIndex + 1) % 5
                return .none

            case .registrationCompleted:
                state.isRegistering = false
                return .cancel(id: "iconTimer")

            case .registrationFailed:
                state.isRegistering = false
                return .cancel(id: "iconTimer")
            }
        }
    }
}
