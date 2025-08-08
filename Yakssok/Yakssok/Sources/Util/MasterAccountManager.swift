//
//  MasterAccountManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/9/25.
//

import Foundation

struct MasterAccountManager {
    static let logoTapThreshold = 5
    static let tapResetTimeInterval: TimeInterval = 3.0

    #if DEBUG
    static let isMasterModeAvailable = true
    #else
    static let isMasterModeAvailable = true // 심사용 - 출시 후 false로 변경 예정
    #endif

    static func getMasterCredentials() -> MasterCredentials? {
        guard isMasterModeAvailable else {
            print("❌ Master mode is disabled")
            return nil
        }

        // Config에서 토큰 읽기
        guard let accessToken = Bundle.main.object(forInfoDictionaryKey: "MASTER_ACCESS_TOKEN") as? String,
              let refreshToken = Bundle.main.object(forInfoDictionaryKey: "MASTER_REFRESH_TOKEN") as? String else {
            print("Master tokens not found in config")
            return nil
        }

        return MasterCredentials(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

struct MasterCredentials {
    let accessToken: String
    let refreshToken: String
}
