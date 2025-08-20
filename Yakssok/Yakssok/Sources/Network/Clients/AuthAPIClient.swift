//
//  AuthAPIClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import ComposableArchitecture
import Foundation

struct AuthAPIClient {
    var login: @Sendable (LoginRequest) async throws -> LoginResponse
    var updateNickname: @Sendable (UpdateNicknameRequest) async throws -> Void
    var logout: @Sendable (LogoutRequest) async throws -> Void
    var refreshToken: @Sendable (String) async throws -> String
    var withdrawal: @Sendable () async throws -> Void
}

extension AuthAPIClient: DependencyKey {
    static let liveValue = Self(
        login: { request in
            let loginResponse: LoginResponse = try await APIClient.shared.authRequest(
                endpoint: .login,
                method: .POST,
                body: request
            )
            return loginResponse
        },

        updateNickname: { request in
            let _: UpdateNicknameResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .updateNickname,
                method: .PUT,
                body: request
            )
        },

        logout: { request in
            let response: UpdateNicknameResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .logout,
                method: .PUT,
                body: request
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }
        },

        refreshToken: { refreshToken in
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response: RefreshTokenResponse = try await APIClient.shared.authRequest(
                endpoint: .refreshToken,
                method: .POST,
                body: request
            )
            return response.body.accessToken
        },

        withdrawal: {
            let response: UpdateNicknameResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .deleteUser,
                method: .DELETE,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }
        }
    )
}

extension DependencyValues {
    var authAPIClient: AuthAPIClient {
        get { self[AuthAPIClient.self] }
        set { self[AuthAPIClient.self] = newValue }
    }
}
