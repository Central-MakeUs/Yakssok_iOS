//
//  NotificationAPIModels.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import Foundation

// MARK: - API Response Models
struct NotificationListResponse: Codable {
    let code: Int
    let message: String
    let body: NotificationListBody
}

struct NotificationListBody: Codable {
    let hasNext: Bool
    let content: [NotificationResponse]
}

struct NotificationResponse: Codable {
    let notificationId: Int
    let notificationType: String
    let senderNickName: String?
    let senderProfileUrl: String?
    let receiverNickName: String?
    let receiverProfileUrl: String?
    let content: String
    let createdAt: String
    let isSentByMe: Bool
}

extension NotificationResponse {
    func toNotificationItem() -> NotificationItem {
        let type = convertAPITypeToNotificationType()

        // ISO 8601 문자열을 Date로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST로 변경
        let timestamp = dateFormatter.date(from: createdAt) ?? Date()

        let senderProfile: UserProfile? = {
            if let senderNickName = senderNickName {
                return UserProfile(
                    name: senderNickName,
                    profileImage: senderProfileUrl,
                    relationship: nil
                )
            }
            return nil
        }()

        let receiverProfile: UserProfile? = {
            if let receiverNickName = receiverNickName {
                return UserProfile(
                    name: receiverNickName,
                    profileImage: receiverProfileUrl,
                    relationship: nil
                )
            }
            return nil
        }()

        return NotificationItem(
            id: String(notificationId),
            type: type,
            message: content,
            senderProfile: senderProfile,
            receiverProfile: receiverProfile,
            timestamp: timestamp,
            isFromMe: isSentByMe
        )
    }

    private func convertAPITypeToNotificationType() -> NotificationType {
        switch notificationType {
        case "FEEDBACK_NAG":
            return isSentByMe ? .naggingSent : .naggingReceived
        case "FEEDBACK_PRAISE":
            return isSentByMe ? .encouragementSent : .encouragementReceived
        case "MEDICATION_TAKE":
            return .medicineAlert
        case "MEDICATION_NOT_TAKEN":
            return .medicineReminder
        case "FRIEND_NOT_TAKE":
            return .mateNotTakingMedicine
        default:
            return .medicineAlert
        }
    }
}
