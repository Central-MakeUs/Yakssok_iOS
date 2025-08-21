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

// MARK: - GET /api/friends/medication-status Response
struct FriendsMedicationStatusResponse: Codable {
    let code: Int
    let message: String
    let body: FriendsMedicationStatusBody
}

struct FriendsMedicationStatusBody: Codable {
    let followingMedicationStatusResponses: [FollowingMedicationStatusResponse]
}

struct FollowingMedicationStatusResponse: Codable {
    let userId: Int
    let nickName: String
    let relationName: String
    let profileImageUrl: String?
    let feedbackType: String // "NAG" or "ENCOURAGEMENT"
    let medicationCount: Int
    let medicationDetails: [MedicationDetail]
}

struct MedicationDetail: Codable {
    let type: String // "CHRONIC", "MENTAL", etc.
    let name: String
    let time: String
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

extension FollowingMedicationStatusResponse {
    func toMateCard() -> MateCard? {
        let medicines = medicationDetails.map { detail in
            Medicine(
                id: "\(userId)-\(detail.name)-\(detail.time)",
                name: detail.name,
                dosage: nil,
                time: convertTimeToDisplayFormat(detail.time),
                color: colorFromMedicationType(detail.type)
            )
        }

        let status: MateStatus
        switch feedbackType {
        case "NAG":
            status = .missedMedicine(count: medicationCount)
        case "PRAISE":
            status = .completed
        default:
            return nil
        }

        return MateCard(
            id: String(userId),
            userName: nickName,
            relationship: relationName,
            profileImage: profileImageUrl,
            status: status,
            todayMedicines: feedbackType == "NAG" ? medicines : [], // 잔소리: 안먹은 약
            completedMedicines: feedbackType == "PRAISE" ? medicines : [] // 칭찬: 먹은 약
        )
    }

    private func convertTimeToDisplayFormat(_ timeString: String) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "a h:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")

        if let time = timeFormatter.date(from: timeString) {
            return displayFormatter.string(from: time)
        }
        return timeString
    }
}
