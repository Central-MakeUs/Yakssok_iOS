//
//  CalendarGridView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import SwiftUI
import YakssokDesignSystem

struct CalendarGridView: View {
    let days: [CalendarDay]
    let selectedDate: Date
    let monthlyStatus: [String: MedicineStatus]
    let onDayTapped: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4, pinnedViews: []) {
            let firstDay = days.first { $0.isCurrentMonth }
            let startWeekday = Calendar.current.component(.weekday, from: firstDay?.date ?? Date())
            let mondayBasedWeekday = (startWeekday + 5) % 7

            ForEach(0..<mondayBasedWeekday, id: \.self) { _ in
                Color.clear
                    .frame(width: 49, height: 67)
            }

            ForEach(days.filter { $0.isCurrentMonth }) { day in
                CalendarDayCell(
                    day: day,
                    selectedDate: selectedDate,
                    medicineStatus: monthlyStatus[day.dateKey] ?? .none,
                    onTapped: { onDayTapped(day.date) }
                )
            }
        }
    }
}
