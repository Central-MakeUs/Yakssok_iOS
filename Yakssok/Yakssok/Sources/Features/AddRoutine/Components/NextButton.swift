//
//  NextButton.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct NextButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YKFont.subtitle2)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: AddRoutineConstants.Layout.nextButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: AddRoutineConstants.Layout.nextButtonCornerRadius)
                        .fill(backgroundColor)
                )
        }
        .disabled(!isEnabled)
    }

    private var textColor: Color {
        isEnabled ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400
    }

    private var backgroundColor: Color {
        isEnabled ? YKColor.Primary.primary400 : YKColor.Neutral.grey200
    }
}
