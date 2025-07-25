//
//  NotificationBubbleView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct NotificationBubbleView: View {
    let notification: NotificationItem

    var body: some View {
        HStack {
            if notification.isFromMe {
                Spacer()
                SentMessageBubble(notification: notification)
            } else {
                ReceivedMessageBubble(notification: notification)
                Spacer()
            }
        }
    }
}

private struct ReceivedMessageBubble: View {
    let notification: NotificationItem

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.bubbleInnerSpacing) {
            SenderInfoView(notification: notification)
            MessageContentView(notification: notification, isReceived: true)
        }
    }
}

private struct SentMessageBubble: View {
    let notification: NotificationItem

    var body: some View {
        VStack(alignment: .trailing, spacing: Constants.bubbleInnerSpacing) {
            ReceiverInfoView(notification: notification)
            MessageContentView(notification: notification, isReceived: false)
        }
    }
}

private struct SenderInfoView: View {
    let notification: NotificationItem

    var body: some View {
        HStack(spacing: Constants.profileSpacing) {
            ProfileImageView(notification: notification)
            SenderNameText(notification: notification)
        }
    }
}

private struct ReceiverInfoView: View {
    let notification: NotificationItem

    var body: some View {
        HStack(spacing: Constants.profileSpacing) {
            // 받는 사람의 프로필 이미지 표시
            Group {
                if let profileImageName = notification.receiverProfile?.profileImage {
                    AsyncImage(url: URL(string: profileImageName)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("default-profile-small")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: Constants.smallProfileSize, height: Constants.smallProfileSize)
                    .clipShape(Circle())
                } else {
                    Image("default-profile-small")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Constants.smallProfileSize, height: Constants.smallProfileSize)
                        .clipShape(Circle())
                }
            }

            Text("\(notification.receiverProfile?.name ?? "")에게 전송")
                .font(YKFont.caption1)
                .foregroundColor(YKColor.Neutral.grey900)
        }
    }
}

private struct MessageContentView: View {
    let notification: NotificationItem
    let isReceived: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: Constants.messageSpacing) {
            if isReceived {
                MessageBubble(notification: notification, isReceived: true)
                TimeText(timestamp: notification.timestamp)
            } else {
                TimeText(timestamp: notification.timestamp)
                MessageBubble(notification: notification, isReceived: false)
            }
        }
    }
}

private struct MessageBubble: View {
    let notification: NotificationItem
    let isReceived: Bool

    var body: some View {
        HStack(spacing: 0) {
            if isReceived {
                Image(notification.triangleImageName)
                    .frame(width: Constants.triangleWidth, height: Constants.triangleHeight)
            }

            Text(notification.displayMessage)
                .font(YKFont.body2)
                .multilineTextAlignment(isReceived ? .leading : .center)
                .foregroundColor(notification.messageTextColor)
                .padding(.horizontal, Constants.messagePadding)
                .padding(.vertical, Constants.messagePadding)
                .background(notification.messageBubbleColor)
                .cornerRadius(Constants.messageCornerRadius)

            if !isReceived {
                Image(notification.triangleImageName)
                    .frame(width: Constants.triangleWidth, height: Constants.triangleHeight)
            }
        }
    }
}

private struct ProfileImageView: View {
    let notification: NotificationItem

    var body: some View {
        Group {
            if notification.isAppNotification {
                Image("logo-profile")
                    .resizable()
                    .frame(width: Constants.profileSize, height: Constants.profileSize)
            } else {
                if let profileImageName = notification.senderProfile?.profileImage {
                    AsyncImage(url: URL(string: profileImageName)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("default-profile-small")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: Constants.profileSize, height: Constants.profileSize)
                    .clipShape(Circle())
                } else {
                    Image("default-profile-small")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Constants.profileSize, height: Constants.profileSize)
                        .clipShape(Circle())
                }
            }
        }
    }
}

private struct SenderNameText: View {
    let notification: NotificationItem

    var body: some View {
        Group {
            if notification.isAppNotification {
                Text("약쏙")
                    .font(Font.custom("Pretendard", size: 14).weight(.bold))
                    .foregroundColor(YKColor.Neutral.grey900)
            } else {
                Text(notification.senderProfile?.name ?? "알 수 없음")
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey900)
            }
        }
    }
}

private struct TimeText: View {
    let timestamp: Date

    var body: some View {
        Text(timeString(from: timestamp))
            .font(YKFont.caption1)
            .foregroundColor(YKColor.Neutral.grey400)
    }

    private func timeString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)분전"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)시간전"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)일전"
        }
    }
}

extension NotificationItem {
    var isAppNotification: Bool {
        switch type {
        case .medicineAlert, .medicineReminder, .mateNotTakingMedicine:
            return true
        case .naggingReceived, .naggingSent, .encouragementReceived, .encouragementSent:
            return false
        }
    }

    var messageBubbleColor: Color {
        switch type {
        case .naggingReceived, .naggingSent:
            return YKColor.Primary.primary400
        case .encouragementReceived, .encouragementSent:
            return YKColor.Sub.blue
        case .medicineAlert, .medicineReminder, .mateNotTakingMedicine:
            return YKColor.Neutral.grey50
        }
    }

    var messageTextColor: Color {
        switch type {
        case .naggingReceived, .naggingSent, .encouragementReceived, .encouragementSent:
            return YKColor.Neutral.grey50
        case .medicineAlert, .medicineReminder, .mateNotTakingMedicine:
            return Color.black
        }
    }

    var triangleImageName: String {
        switch type {
        case .naggingReceived:
            return "triangle-orange-side"
        case .naggingSent:
            return "triangle-orange-me"
        case .encouragementReceived:
            return "triangle-blue-side"
        case .encouragementSent:
            return "triangle-blue-me"
        case .medicineAlert, .medicineReminder, .mateNotTakingMedicine:
            return "triangle-white"
        }
    }

    var displayMessage: String {
        if type == .naggingReceived || type == .encouragementReceived {
            if message.count > 15 {
                return String(message.prefix(15)) + "..."
            }
        }
        return message
    }
}

private enum Constants {
    static let bubbleInnerSpacing: CGFloat = 4
    static let profileSpacing: CGFloat = 4
    static let messageSpacing: CGFloat = 12
    static let profileSize: CGFloat = 32
    static let smallProfileSize: CGFloat = 20
    static let triangleWidth: CGFloat = 11
    static let triangleHeight: CGFloat = 15
    static let messagePadding: CGFloat = 16
    static let messageCornerRadius: CGFloat = 12
}
