//
//  MonthNavigationView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import SwiftUI
import YakssokDesignSystem

struct MonthNavigationView: View {
    let currentMonth: String
    let onPreviousTapped: () -> Void
    let onNextTapped: () -> Void

    var body: some View {
        HStack {
            Text(currentMonth)
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey900)

            Spacer()

            HStack(spacing: 0) {
                Button(action: onPreviousTapped) {
                    Image("arrow-left")
                        .frame(width: 24, height: 24)
                        .padding(.vertical, 8)
                }
                .frame(width: 46, height: 36)
                .background(YKColor.Neutral.grey100)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )

                Rectangle()
                    .fill(YKColor.Neutral.grey200)
                    .frame(width: 1, height: 36)

                Button(action: onNextTapped) {
                    Image("arrow-right")
                        .frame(width: 24, height: 24)
                        .padding(.vertical, 8)
                }
                .frame(width: 46, height: 36)
                .background(YKColor.Neutral.grey100)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 12
                    )
                )
            }
        }
    }
}
