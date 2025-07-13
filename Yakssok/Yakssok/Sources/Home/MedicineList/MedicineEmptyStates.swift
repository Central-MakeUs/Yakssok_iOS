//
//  MedicineEmptyStates.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import SwiftUI
import YakssokDesignSystem

struct NoRoutinesView: View {
    let addMedicineAction: () -> Void

    var body: some View {
        MedicineEmptyStateView(
            iconName: "pill",
            title: "복약 까먹지 않게",
            subtitle: "알림을 드려요!",
            buttonTitle: "복약추가하기",
            buttonAction: addMedicineAction
        )
    }
}

struct NoMedicineTodayView: View {
    let addMedicineAction: () -> Void

    var body: some View {
        MedicineEmptyStateView(
            iconName: "pill-empty",
            title: "먹을 약이 없어요.",
            subtitle: "오늘은 쉬어가는 날!",
            buttonTitle: "복약추가하기",
            buttonAction: addMedicineAction
        )
    }
}

private struct MedicineEmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonAction: () -> Void

    var body: some View {
        VStack(spacing: Layout.mainSpacing) {
            EmptyStateContentView(
                iconName: iconName,
                title: title,
                subtitle: subtitle
            )
            EmptyStateActionButton(
                title: buttonTitle,
                action: buttonAction
            )
        }
    }
}

private struct EmptyStateContentView: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Layout.contentSpacing) {
            EmptyStateIcon(iconName: iconName)
            EmptyStateTextContent(title: title, subtitle: subtitle)
        }
    }
}

private struct EmptyStateIcon: View {
    let iconName: String

    var body: some View {
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: Layout.iconSize, height: Layout.iconSize)
    }
}

private struct EmptyStateTextContent: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Layout.textSpacing) {
            Text(title)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey900)
            Text(subtitle)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey900)
        }
    }
}

private struct EmptyStateActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.buttonContentSpacing) {
                Text(title)
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey600)
                Image(systemName: "plus")
                    .font(.system(size: Layout.buttonIconSize, weight: .bold))
                    .foregroundColor(YKColor.Neutral.grey400)
            }
            .padding(.horizontal, Layout.buttonHorizontalPadding)
            .padding(.vertical, Layout.buttonVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                    .stroke(YKColor.Neutral.grey200, lineWidth: Layout.buttonBorderWidth)
            )
        }
    }
}

private enum Layout {
    static let mainSpacing: CGFloat = 20
    static let contentSpacing: CGFloat = 24
    static let textSpacing: CGFloat = 8
    static let iconSize: CGFloat = 86
    static let buttonContentSpacing: CGFloat = 4
    static let buttonHorizontalPadding: CGFloat = 12
    static let buttonVerticalPadding: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 12
    static let buttonBorderWidth: CGFloat = 1
    static let buttonIconSize: CGFloat = 14
}
