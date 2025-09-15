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
    private let keychainAccessGroup: String? = nil

    private let refreshManager = TokenRefreshManager()

    private var cachedAccessToken: String?
    private var cachedRefreshToken: String?
    private var lastCacheTime: Date?

    private init() {}

    var accessToken: String? {
        get {
            if let cached = cachedAccessToken,
               let lastTime = lastCacheTime,
               Date().timeIntervalSince(lastTime) < 5 {
                return cached
            }

            let token = getTokenFromKeychain(for: accessTokenKey)
            cachedAccessToken = token
            lastCacheTime = Date()
            return token
        }
        set {
            cachedAccessToken = newValue
            lastCacheTime = Date()

            if let token = newValue {
                saveTokenToKeychain(token, for: accessTokenKey)
            } else {
                deleteTokenFromKeychain(for: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get {
            if let cached = cachedRefreshToken,
               let lastTime = lastCacheTime,
               Date().timeIntervalSince(lastTime) < 5 {
                return cached
            }

            let token = getTokenFromKeychain(for: refreshTokenKey)
            cachedRefreshToken = token
            lastCacheTime = Date()
            return token
        }
        set {
            cachedRefreshToken = newValue
            lastCacheTime = Date()

            if let token = newValue {
                saveTokenToKeychain(token, for: refreshTokenKey)
            } else {
                deleteTokenFromKeychain(for: refreshTokenKey)
            }
        }
    }

    var isLoggedIn: Bool {
        return accessToken != nil && refreshToken != nil
    }

    func saveTokens(_ accessToken: String, _ refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearTokens() {
        cachedAccessToken = nil
        cachedRefreshToken = nil
        lastCacheTime = nil

        accessToken = nil
        refreshToken = nil
    }

    func refreshCachedTokens() {
        cachedAccessToken = nil
        cachedRefreshToken = nil
        lastCacheTime = nil

        let _ = accessToken
        let _ = refreshToken
    }

    func refreshOnceOnLaunch() async throws {
        try await refreshManager.forceRefreshNow()
        refreshCachedTokens()
    }

    @discardableResult
    private func saveTokenToKeychain(_ token: String, for key: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    private func getTokenFromKeychain(for key: String) -> String? {
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

    private func deleteTokenFromKeychain(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    func getValidTokenAsync() async throws -> String {
        return try await refreshManager.getValidToken()
    }
}

actor TokenRefreshManager {
    private enum RefreshState {
        case idle
        case refreshing(Task<String, Error>)
    }

    private var state: RefreshState = .idle
    private let maxRetries = 3

    func getValidToken() async throws -> String {
        switch state {
        case .idle:
            if let token = TokenManager.shared.accessToken {
                return token
            }

            let task = Task<String, Error> {
                try await self.performTokenRefreshWithRetry()
            }
            state = .refreshing(task)
            defer { state = .idle }

            return try await task.value

        case .refreshing(let task):
            return try await task.value
        }
    }

    @discardableResult
    func forceRefreshNow() async throws -> String {
        return try await getValidToken()
    }

    private func performTokenRefreshWithRetry(attempt: Int = 0) async throws -> String {
        guard let refreshToken = TokenManager.shared.refreshToken, !refreshToken.isEmpty else {
            throw APIError.serverError(401)
        }

        do {
            let req = RefreshTokenRequest(refreshToken: refreshToken)
            let res: RefreshTokenResponse = try await APIClient.shared.authRequest(
                endpoint: .refreshToken,
                method: .POST,
                body: req
            )
            TokenManager.shared.accessToken = res.body.accessToken
            return res.body.accessToken

        } catch {
            if attempt >= maxRetries { throw error }
            let delaySec = pow(2.0, Double(attempt + 1))
            try await Task.sleep(nanoseconds: UInt64(delaySec * 1_000_000_000))
            return try await performTokenRefreshWithRetry(attempt: attempt + 1)
        }
    }
}

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
            TokenManager.shared.saveTokens(accessToken, refreshToken)
        },
        clearTokens: {
            TokenManager.shared.clearTokens()
        }
    )
}

extension DependencyValues {
    var tokenManager: TokenManagerClient {
        get { self[TokenManagerClient.self] }
        set { self[TokenManagerClient.self] = newValue }
    }
}
