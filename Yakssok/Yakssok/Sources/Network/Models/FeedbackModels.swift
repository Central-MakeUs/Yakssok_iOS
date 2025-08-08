//
//  FeedbackModels.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import Foundation

// MARK: - Request
struct FeedbackRequest: Codable {
    let receiverId: Int
    let message: String
    let type: String // praise or nag
}

// MARK: - Response
struct FeedbackResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody?
}

extension FeedbackRequest {
    /// 잔소리 피드백 생성
    static func nag(receiverId: Int, message: String) -> FeedbackRequest {
        return FeedbackRequest(
            receiverId: receiverId,
            message: message,
            type: "nag"
        )
    }

    /// 칭찬 피드백 생성
    static func praise(receiverId: Int, message: String) -> FeedbackRequest {
        return FeedbackRequest(
            receiverId: receiverId,
            message: message,
            type: "praise"
        )
    }
}
