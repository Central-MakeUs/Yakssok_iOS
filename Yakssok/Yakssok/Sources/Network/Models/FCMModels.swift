//
//  FCMModels.swift
//  Yakssok
//
//  Created by 김사랑 on 8/10/25.
//

import Foundation

// MARK: - FCM 토큰 등록
struct FCMTokenRequest: Codable {
    let deviceId: String
    let fcmToken: String
    let alertOn: Bool
}

struct FCMTokenResponse: Codable {
    let code: Int
    let message: String
}

// MARK: - FCM Data-only 메시지 (복약 알림용)
struct FCMDataMessage: Codable {
    let title: String
    let body: String
    let soundType: String
}

// MARK: - 사운드 타입
enum FCMSoundType: String, CaseIterable {
    case feelGood = "FEEL_GOOD"
    case pillShake = "PILL_SHAKE"
    case scold = "SCOLD"
    case call = "CALL"
    case vibration = "VIBRATION"

    var resourceName: String {
        switch self {
        case .feelGood: return "feelGood"
        case .pillShake: return "pillShake"
        case .scold: return "scold"
        case .call: return "call"
        case .vibration: return "vibration"
        }
    }

    var fileName: String {
        switch self {
        case .feelGood: return "feelGood.caf"
        case .pillShake: return "pillShake.caf"
        case .scold: return "scold.caf"
        case .call: return "call.caf"
        case .vibration: return "vibration.caf"
        }
    }

    var isAvailable: Bool {
        return Bundle.main.url(forResource: resourceName, withExtension: "caf") != nil
    }

}
