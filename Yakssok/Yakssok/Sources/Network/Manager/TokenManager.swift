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
        return accessToken != nil && refreshToken != nil
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearAllTokens() {
        accessToken = nil
        refreshToken = nil
    }

    private func saveToken(_ token: String, for key: String) {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: "VT34K852T5.com.yakssok.app",
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getToken(for key: String) -> String? {
        let queryWithoutGroup: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result1: AnyObject?
        let status1 = SecItemCopyMatching(queryWithoutGroup as CFDictionary, &result1)

        let queryWithGroup: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: "VT34K852T5.com.yakssok.app"
        ]

        var result2: AnyObject?
        let status2 = SecItemCopyMatching(queryWithGroup as CFDictionary, &result2)

        if status2 == errSecSuccess {
            guard let data = result2 as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }
            return token
        } else if status1 == errSecSuccess {
            guard let data = result1 as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }
            return token
        }

        return nil
    }

    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: "VT34K852T5.com.yakssok.app"
        ]

        SecItemDelete(query as CFDictionary)
    }

    func getValidTokenAsync() async throws -> String {
        return try await refreshManager.getValidToken()
    }

    func migrateKeychainIfNeeded() {
        let oldQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accessTokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(oldQuery as CFDictionary, &result)

        if status == errSecSuccess {
            SecItemDelete(oldQuery as CFDictionary)

            let oldRefreshQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: refreshTokenKey
            ]
            SecItemDelete(oldRefreshQuery as CFDictionary)
        }
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
            if let token = TokenManager.shared.accessToken {
                return token
            }

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
