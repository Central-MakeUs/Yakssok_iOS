//
//  MateCardItemView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MateCardItemView: View {
    let card: MateCard
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileSection(card: card)
            Spacer().frame(height: Layout.profileToStatusSpacing)
            StatusSection(card: card)
            Spacer().frame(height: Layout.statusToButtonSpacing)
            ActionButton(card: card, onTap: onTap)
        }
        .padding(Layout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .fill(YKColor.Neutral.grey50)
        )
    }
}

private struct ProfileSection: View {
    let card: MateCard

    var body: some View {
        HStack(spacing: Layout.profileImageSpacing) {
            ProfileImageView(card: card)
            UserInfoView(card: card)
        }
    }
}

private struct ProfileImageView: View {
    let card: MateCard

    var body: some View {
        Circle()
            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
            .overlay {
                if let profileImageURL = card.profileImage {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                    } placeholder: {
                        Image("default-profile-small")
                            .resizable()
                            .scaledToFill()
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                    }
                } else {
                    Image("default-profile-small")
                        .resizable()
                        .scaledToFill()
                        .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                        .clipShape(Circle())
                }
            }
    }
}

private struct UserInfoView: View {
    let card: MateCard

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.userInfoSpacing) {
            Text(card.relationship)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey400)

            Text(card.userName)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey600)
        }
    }
}

private struct StatusSection: View {
    let card: MateCard

    var body: some View {
        HStack(spacing: Layout.statusIconSpacing) {
            statusText

            if case .completed = card.status {
                Image("hands-up")
                    .frame(width: Layout.statusIconSize, height: Layout.statusIconSize)
            }
        }
    }

    private var statusText: some View {
        switch card.status {
        case .missedMedicine(let count):
            return (
                Text("안먹은 약 · ")
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey500)
                + Text("\(count)개")
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey900)
                    .fontWeight(.semibold)
            )
        case .completed:
            return Text("다먹었어요!")
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey500)
        }
    }
}

private struct ActionButton: View {
    let card: MateCard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(buttonText)
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey50)
                .padding(.vertical, Layout.buttonVerticalPadding)
                .padding(.horizontal, Layout.buttonHorizontalPadding)
                .frame(width: Layout.buttonWidth)
                .background(
                    RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                        .fill(buttonBackgroundColor)
                )
        }
    }

    private var buttonText: String {
        switch card.status {
        case .missedMedicine:
            return "잔소리 보내기"
        case .completed:
            return "칭찬 보내기"
        }
    }

    private var buttonBackgroundColor: Color {
        switch card.status {
        case .missedMedicine:
            return YKColor.Neutral.grey900
        case .completed:
            return YKColor.Sub.blue
        }
    }
}

private enum Layout {
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let profileImageSize: CGFloat = 52
    static let profileImageSpacing: CGFloat = 8
    static let userInfoSpacing: CGFloat = 2
    static let profileToStatusSpacing: CGFloat = 20
    static let statusToButtonSpacing: CGFloat = 8
    static let statusIconSpacing: CGFloat = 8
    static let statusIconSize: CGFloat = 20
    static let buttonWidth: CGFloat = 120
    static let buttonVerticalPadding: CGFloat = 8
    static let buttonHorizontalPadding: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 8
}
