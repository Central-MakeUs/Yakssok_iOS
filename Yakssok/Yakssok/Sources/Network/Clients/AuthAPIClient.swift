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
    var join: @Sendable (JoinRequest) async throws -> Void
    var logout: @Sendable () async throws -> Void
    var refreshToken: @Sendable (String) async throws -> String
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

        join: { request in
            let _: JoinResponse = try await APIClient.shared.authRequest(
                endpoint: .join,
                method: .POST,
                body: request
            )
        },

        logout: {
            let response: JoinResponse = try await APIClient.shared.request(
                endpoint: .logout,
                method: .PUT,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }
        },

        refreshToken: { refreshToken in
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response: RefreshTokenResponse = try await APIClient.shared.request(
                endpoint: .refreshToken,
                method: .POST,
                body: request
            )
            return response.body.accessToken
        }
    )
}

extension DependencyValues {
    var authAPIClient: AuthAPIClient {
        get { self[AuthAPIClient.self] }
        set { self[AuthAPIClient.self] = newValue }
    }
}
