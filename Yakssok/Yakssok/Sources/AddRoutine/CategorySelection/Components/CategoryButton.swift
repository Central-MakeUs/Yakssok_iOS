//
//  CategoryButton.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct CategoryButton: View {
    let category: MedicineCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Circle()
                    .fill(dotColor)
                    .frame(
                        width: AddRoutineConstants.Layout.categoryDotSize,
                        height: AddRoutineConstants.Layout.categoryDotSize
                    )

                Text(category.name)
                    .font(YKFont.body2)
                    .foregroundColor(textColor)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: AddRoutineConstants.Layout.categoryButtonCornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AddRoutineConstants.Layout.categoryButtonCornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
    }

    private var dotColor: Color {
        isSelected ? category.colorType.textColor : YKColor.Neutral.grey200
    }

    private var textColor: Color {
        isSelected ? category.colorType.textColor : YKColor.Neutral.grey700
    }

    private var backgroundColor: Color {
        isSelected ? category.colorType.backgroundColor : Color.clear
    }

    private var borderColor: Color {
        isSelected ? category.colorType.textColor : YKColor.Neutral.grey200
    }
}
