//
//  CalendarDayCell.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import SwiftUI
import YakssokDesignSystem

struct CalendarDayCell: View {
    let day: CalendarDay
    let selectedDate: Date
    let medicineStatus: MedicineStatus
    let onTapped: () -> Void

    private var isSelected: Bool {
        Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
    }

    var body: some View {
        if day.isCurrentMonth {
            Button(action: onTapped) {
                VStack(alignment: .center, spacing: 0) {
                    Text("\(day.day)")
                        .font(YKFont.body2)
                        .foregroundColor(dateTextColor)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(dateBackgroundColor)
                        .cornerRadius(999)

                    iconView
                }
                .frame(width: 49, height: 67, alignment: .top)
            }
            .buttonStyle(.plain)
        } else {
            Color.clear.frame(width: 49, height: 67)
        }
    }

    private var dateTextColor: Color {
        if isSelected {
            return YKColor.Neutral.grey50
        } else if day.isToday {
            return YKColor.Primary.primary400
        } else {
            return YKColor.Neutral.grey500
        }
    }

    private var dateBackgroundColor: Color {
        if isSelected {
            return YKColor.Neutral.grey900
        } else {
            return Color.clear
        }
    }

    private var iconView: some View {
        Group {
            let today = Date()

            if day.isToday {
                switch medicineStatus {
                case .completed:
                    Image(fixedCompletedIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                case .incomplete:
                    Image(fixedIncompleteIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                case .none:
                    Image("calendar-basic")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            } else if day.date < today {
                switch medicineStatus {
                case .completed:
                    Image(fixedCompletedIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                case .incomplete:
                    Image(fixedIncompleteIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                case .none:
                    Image("calendar-basic")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            } else {
                switch medicineStatus {
                case .completed:
                    Image(fixedCompletedIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                case .incomplete:
                    Image("calendar-basic")
                        .resizable()
                        .frame(width: 40, height: 40)
                case .none:
                    Image("calendar-basic")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
        }
    }

    private var fixedCompletedIcon: String {
        let iconIndex = (day.day % 6) + 1
        return "calendar-done-\(iconIndex)"
    }

    private var fixedIncompleteIcon: String {
        let iconIndex = (day.day % 6) + 1
        return "calendar-not-done-\(iconIndex)"
    }
}
