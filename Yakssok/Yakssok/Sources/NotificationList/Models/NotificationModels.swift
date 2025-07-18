//
//  NotificationModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import Foundation

struct NotificationItem: Equatable, Identifiable {
    let id: String
    let type: NotificationType
    let message: String
    let senderProfile: UserProfile?
    let receiverProfile: UserProfile?
    let timestamp: Date
    let isFromMe: Bool
}

enum NotificationType: Equatable {
    case naggingReceived
    case naggingSent
    case encouragementReceived
    case encouragementSent
    case medicineAlert
    case medicineReminder
    case mateNotTakingMedicine
}

struct UserProfile: Equatable {
    let name: String
    let profileImage: String?
    let relationship: String?
}
