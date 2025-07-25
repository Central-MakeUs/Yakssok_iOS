//
//  KakaoAuthClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import ComposableArchitecture
import Dependencies
import KakaoSDKAuth
import KakaoSDKUser
import Foundation

struct KakaoAuthClient {
    var login: @Sendable () async throws -> String
    var logout: @Sendable () async throws -> Void
    var isLoggedIn: @Sendable () -> Bool
}

extension KakaoAuthClient: DependencyKey {
    static let liveValue = Self(
        login: {
            return try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    // 카카오톡 설치 여부 확인
                    if UserApi.isKakaoTalkLoginAvailable() {
                        // 카카오톡으로 로그인
                        UserApi.shared.loginWithKakaoTalk { (result, error) in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let token = result {
                                continuation.resume(returning: token.accessToken)
                            } else {
                                continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 오류"]))
                            }
                        }
                    } else {
                        // 카카오계정으로 로그인 (웹)
                        UserApi.shared.loginWithKakaoAccount { (result, error) in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let token = result {
                                continuation.resume(returning: token.accessToken)
                            } else {
                                continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 오류"]))
                            }
                        }
                    }
                }
            }
        },
        
        logout: {
            return try await withCheckedThrowingContinuation { continuation in
                UserApi.shared.logout { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        },
        
        isLoggedIn: {
            return AuthApi.hasToken()
        }
    )
}

extension DependencyValues {
    var kakaoAuthClient: KakaoAuthClient {
        get { self[KakaoAuthClient.self] }
        set { self[KakaoAuthClient.self] = newValue }
    }
}
