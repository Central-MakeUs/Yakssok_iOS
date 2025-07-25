//
//  CalendarWeekdayHeaderView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import SwiftUI
import YakssokDesignSystem

struct CalendarWeekdayHeaderView: View {
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                VStack(alignment: .center, spacing: 8) {
                    Text(weekday)
                        .font(YKFont.body2)
                        .foregroundColor(YKColor.Neutral.grey400)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}
