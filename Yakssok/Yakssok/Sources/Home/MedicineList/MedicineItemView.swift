//
//  MedicineItemView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import SwiftUI
import YakssokDesignSystem

struct MedicineItemView: View {
    let medicine: Medicine
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .fill(YKColor.Neutral.grey100)
            HStack {
                Spacer()
                Rectangle()
                    .fill(isCompleted ? YKColor.Neutral.grey200 : YKColor.Primary.primary400)
                    .frame(width: Layout.backgroundPadding + Layout.toggleButtonSize)
            }
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
            HStack(spacing: Layout.horizontalSpacing) {
                MedicineColorDot(color: medicine.color)
                MedicineInfoView(medicine: medicine, isCompleted: isCompleted)
                Spacer()
                MedicineToggleButton(isCompleted: isCompleted, onToggle: onToggle)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
        }
    }
}

private struct MedicineColorDot: View {
    let color: MedicineColor

    var body: some View {
        Circle()
            .fill(colorValue)
            .frame(width: Layout.colorDotSize, height: Layout.colorDotSize)
    }

    private var colorValue: Color {
        switch color {
        case .purple: return YKColor.Sub.purple
        case .yellow: return YKColor.Sub.yellow
        case .blue: return YKColor.Sub.blue
        case .green: return YKColor.Sub.green
        case .pink: return YKColor.Sub.pink
        }
    }
}

private struct MedicineInfoView: View {
    let medicine: Medicine
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: Layout.infoSpacing) {
            Text(medicine.name)
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey950)
                .strikethrough(isCompleted)
            Rectangle()
                .fill(YKColor.Neutral.grey300)
                .frame(width: 1, height: 12)
            Text(medicine.time)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey400)
        }
    }
}

private struct MedicineToggleButton: View {
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(isCompleted ? "check-grey" : "check-orange")
                .frame(width: Layout.toggleButtonSize, height: Layout.toggleButtonSize)
        }
    }
}

private enum Layout {
    static let horizontalSpacing: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 16
    static let infoSpacing: CGFloat = 8
    static let colorDotSize: CGFloat = 8
    static let toggleButtonSize: CGFloat = 28
    static let toggleIconSize: CGFloat = 16
    static let backgroundPadding: CGFloat = 36
}
