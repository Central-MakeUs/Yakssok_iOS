//
//  TokenManager.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import Foundation
import Security
import Dependencies

class TokenManager {
    static let shared = TokenManager()

    private let accessTokenKey = "yakssok_access_token"
    private let refreshTokenKey = "yakssok_refresh_token"

    private let refreshManager = TokenRefreshManager()

    private init() {}

    // MARK: - Public Properties
    var accessToken: String? {
        get { getToken(for: accessTokenKey) }
        set {
            if let token = newValue {
                saveToken(token, for: accessTokenKey)
            } else {
                deleteToken(for: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get { getToken(for: refreshTokenKey) }
        set {
            if let token = newValue {
                saveToken(token, for: refreshTokenKey)
            } else {
                deleteToken(for: refreshTokenKey)
            }
        }
    }

    var isLoggedIn: Bool {
        // 액세스 토큰과 리프레시 토큰이 모두 있어야 로그인 상태임
        return accessToken != nil && refreshToken != nil
    }

    // MARK: - Public Methods
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearAllTokens() {
        accessToken = nil
        refreshToken = nil
    }

    // MARK: - Private Keychain Methods
    private func saveToken(_ token: String, for key: String) {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // 기존 토큰이 있으면 삭제
        SecItemDelete(query as CFDictionary)

        // 새 토큰 저장
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("Keychain 저장 실패: \(key), status: \(status)")
        }
    }

    private func getToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
        } else if status != errSecItemNotFound {
            print("토큰 삭제 실패: \(key), status: \(status)")
        }
    }

    func getValidTokenAsync() async throws -> String {
        return try await refreshManager.getValidToken()
    }
}

// MARK: - TokenRefreshManager Actor
actor TokenRefreshManager {
    private enum RefreshState {
        case idle
        case refreshing(Task<String, Error>)
    }

    private var refreshState: RefreshState = .idle

    func getValidToken() async throws -> String {
        switch refreshState {
        case .idle:
            // 토큰이 있고 유효하면 바로 반환
            if let token = TokenManager.shared.accessToken {
                return token
            }

            // 새로운 토큰 갱신 시작
            let refreshTask = Task<String, Error> {
                try await performTokenRefresh()
            }
            refreshState = .refreshing(refreshTask)

            do {
                let newToken = try await refreshTask.value
                refreshState = .idle
                return newToken
            } catch {
                refreshState = .idle
                throw error
            }

        case .refreshing(let existingTask):
            // 이미 진행 중인 갱신 작업 기다리기
            return try await existingTask.value
        }
    }

    private func performTokenRefresh() async throws -> String {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            throw APIError.serverError(401)
        }

        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: RefreshTokenResponse = try await APIClient.shared.authRequest(
            endpoint: .refreshToken,
            method: .POST,
            body: request
        )

        TokenManager.shared.accessToken = response.body.accessToken
        return response.body.accessToken
    }
}

// MARK: - TokenManager Dependency
struct TokenManagerClient {
    var accessToken: @Sendable () -> String?
    var refreshToken: @Sendable () -> String?
    var isLoggedIn: @Sendable () -> Bool
    var saveTokens: @Sendable (String, String) -> Void
    var clearTokens: @Sendable () -> Void
}

extension TokenManagerClient: DependencyKey {
    static let liveValue = Self(
        accessToken: { TokenManager.shared.accessToken },
        refreshToken: { TokenManager.shared.refreshToken },
        isLoggedIn: { TokenManager.shared.isLoggedIn },
        saveTokens: { accessToken, refreshToken in
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        },
        clearTokens: {
            TokenManager.shared.clearAllTokens()
        }
    )
}

extension DependencyValues {
    var tokenManager: TokenManagerClient {
        get { self[TokenManagerClient.self] }
        set { self[TokenManagerClient.self] = newValue }
    }
}
