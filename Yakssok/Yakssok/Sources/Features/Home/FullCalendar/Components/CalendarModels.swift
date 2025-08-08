//
//  CalendarModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import Foundation

struct CalendarDay: Equatable, Identifiable {
    let id = UUID()
    let date: Date
    let day: Int
    let isCurrentMonth: Bool
    let isToday: Bool

    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum MedicineStatus: Equatable {
    case completed
    case incomplete
    case none
}
