//
//  MockNotificationData.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import Foundation

struct MockNotificationData {
    enum DataType: CaseIterable {
        case empty
        case sample
        case many

        var description: String {
            switch self {
            case .empty: return "알림 없음"
            case .sample: return "기본 알림"
            case .many: return "많은 알림"
            }
        }
    }

    static func notifications(for type: DataType) -> [NotificationItem] {
        switch type {
        case .empty: return emptyNotifications
        case .sample: return sampleNotifications
        case .many: return manyNotifications
        }
    }

    private static let emptyNotifications: [NotificationItem] = []

    private static let sampleNotifications: [NotificationItem] = [
        NotificationItem(
            id: "1",
            type: .naggingReceived,
            message: "비타민 꼭 챙겨먹어!",
            senderProfile: UserProfile(name: "신짱구", profileImage: nil, relationship: "아들"),
            receiverProfile: nil,
            timestamp: Date().addingTimeInterval(-1 * 3600),
            isFromMe: false
        ),
        // 신형만에게서 응원 받음
        NotificationItem(
            id: "2",
            type: .encouragementReceived,
            message: "오늘도 잘 챙겨먹었네!",
            senderProfile: UserProfile(name: "신형만", profileImage: "https://randomuser.me/api/portraits/med/men/11.jpg", relationship: "남편"),
            receiverProfile: nil,
            timestamp: Date().addingTimeInterval(-2 * 3600),
            isFromMe: false
        ),
        // 앱 자체 알림
        NotificationItem(
            id: "3",
            type: .medicineAlert,
            message: "비타민D 챙길 시간이에요! 약 먹고, 섭취 완료 처리해주세요!",
            senderProfile: UserProfile(name: "약쏙", profileImage: "yakssok-logo", relationship: nil),
            receiverProfile: nil,
            timestamp: Date().addingTimeInterval(-3 * 3600),
            isFromMe: false
        ),
        NotificationItem(
            id: "4",
            type: .naggingSent,
            message: "약 꼭 챙겨먹어!",
            senderProfile: nil,
            receiverProfile: UserProfile(name: "봉미선", profileImage: "https://randomuser.me/api/portraits/med/women/2.jpg", relationship: "아내"),
            timestamp: Date().addingTimeInterval(-4 * 3600),
            isFromMe: true
        ),
        NotificationItem(
            id: "5",
            type: .encouragementSent,
            message: "잘하고 있어요!",
            senderProfile: nil,
            receiverProfile: UserProfile(name: "신형만", profileImage: "https://randomuser.me/api/portraits/med/men/11.jpg", relationship: "남편"),
            timestamp: Date().addingTimeInterval(-5 * 3600),
            isFromMe: true
        )
    ]

    private static let manyNotifications: [NotificationItem] = sampleNotifications + [
        NotificationItem(
            id: "6",
            type: .encouragementSent,
            message: "정말 대단하군!",
            senderProfile: nil,
            receiverProfile: UserProfile(name: "신짱구", profileImage: nil, relationship: "아들"),
            timestamp: Date().addingTimeInterval(-6 * 3600),
            isFromMe: true
        ),
        NotificationItem(
            id: "7",
            type: .naggingReceived,
            message: "또 약 안먹었네! 건강이 제일 중요해!",
            senderProfile: UserProfile(name: "봉미선", profileImage: "https://randomuser.me/api/portraits/med/women/2.jpg", relationship: "아내"),
            receiverProfile: nil,
            timestamp: Date().addingTimeInterval(-7 * 3600),
            isFromMe: false
        ),
        // 추가 앱 알림
        NotificationItem(
            id: "8",
            type: .medicineReminder,
            message: "오메가3 복용 시간입니다.",
            senderProfile: UserProfile(name: "약쏙", profileImage: "yakssok-logo", relationship: nil),
            receiverProfile: nil,
            timestamp: Date().addingTimeInterval(-8 * 3600),
            isFromMe: false
        )
    ]
}
