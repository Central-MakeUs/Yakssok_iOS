//
//  MateProfileView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import SwiftUI
import YakssokDesignSystem

struct MateProfileView: View {
    let user: User
    let isSelected: Bool
    let profileSize: CGFloat
    let selectedBorderWidth: CGFloat
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            profileImageButton
            Text(user.name)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey600)
        }
    }
}

private extension MateProfileView {
    var profileImageButton: some View {
        Button(action: action) {
            profileImage
        }
        .overlay(
            RoundedRectangle(cornerRadius: profileSize)
                .inset(by: -1)
                .stroke(
                    isSelected ?
                    LinearGradient(
                        colors: [YKColor.Primary.primary300, YKColor.Primary.primary600],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                        LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: selectedBorderWidth
                )
        )
    }

    var profileImage: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: profileSize, height: profileSize)
            .background(
                Group {
                    if let profileImageURL = user.profileImage {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: profileSize, height: profileSize)
                                .clipped()
                        } placeholder: {
                            defaultProfileIcon
                        }
                    } else {
                        defaultProfileIcon
                    }
                }
            )
            .background(YKColor.Neutral.grey200)
            .cornerRadius(profileSize)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
    }

    var defaultProfileIcon: some View {
        Image("default-profile-small")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: profileSize, height: profileSize)
            .clipped()
    }
}
