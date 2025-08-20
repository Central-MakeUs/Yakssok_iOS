//
//  AuthModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/26/25.
//

import Foundation

struct LoginRequest: Codable {
    let oauthAuthorizationCode: String
    let oauthType: String
    let nonce: String?

    init(oauthAuthorizationCode: String, oauthType: String, nonce: String? = nil) {
        self.oauthAuthorizationCode = oauthAuthorizationCode
        self.oauthType = oauthType
        self.nonce = nonce
    }
}

struct LoginResponse: Codable, Equatable {
    let code: Int
    let message: String
    let body: LoginBody
}

struct LoginBody: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let isInitialized: Bool
}

struct UpdateNicknameRequest: Codable {
    let nickName: String
}

struct UpdateNicknameResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
}

struct JoinResponse: Codable {
    let code: Int
    let message: String
    let body: [String: String]?
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable, Equatable {
    let code: Int
    let message: String
    let body: RefreshTokenBody
}

struct RefreshTokenBody: Codable, Equatable {
    let accessToken: String
}

struct LogoutRequest: Codable {
    let deviceId: String
}
