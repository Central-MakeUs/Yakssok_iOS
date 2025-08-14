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

    var fileName: String {
        switch self {
        case .feelGood: return "기분 좋아지는 소리"
        case .pillShake: return "약통 흔드는 소리"
        case .scold: return "잔소리 해주는 소리"
        case .call: return "전화온 듯한 소리"
        case .vibration: return "진동 소리"
        }
    }
}
