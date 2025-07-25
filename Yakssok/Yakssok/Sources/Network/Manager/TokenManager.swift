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
        return accessToken != nil
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

        SecItemDelete(query as CFDictionary)
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
