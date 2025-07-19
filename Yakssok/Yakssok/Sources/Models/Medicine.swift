//
//  Medicine.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import Foundation
import SwiftUI
import YakssokDesignSystem

struct Medicine: Equatable, Identifiable {
    let id: String
    let name: String
    let dosage: String?
    let time: String
    let color: MedicineColor
}

struct MedicineRoutine: Equatable, Identifiable {
    let id: String
    let medicineName: String
    let schedule: [String]

    var category: MedicineCategory
    var frequency: MedicineFrequency
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
    var status: MedicineStatus

    init(id: String, medicineName: String, schedule: [String]) {
        self.id = id
        self.medicineName = medicineName
        self.schedule = schedule
        self.category = MedicineCategory.defaultCategories[2]
        self.frequency = MedicineFrequency(type: .daily, times: [])
        self.startDate = nil
        self.endDate = nil
        self.createdAt = Date()
        self.status = .taking
    }

    init(id: String, medicineName: String, schedule: [String], category: MedicineCategory, frequency: MedicineFrequency, startDate: Date?, endDate: Date?, createdAt: Date, status: MedicineStatus) {
        self.id = id
        self.medicineName = medicineName
        self.schedule = schedule
        self.category = category
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.status = status
    }

    enum MedicineStatus: Equatable {
        case beforeTaking
        case taking
        case completed

        var displayText: String {
            switch self {
            case .beforeTaking: return "복약 전"
            case .taking: return "복약 중"
            case .completed: return "복약 종료"
            }
        }

        var backgroundColor: Color {
            switch self {
            case .beforeTaking: return YKColor.Neutral.grey100
            case .taking: return YKColor.Primary.primary100
            case .completed: return YKColor.Neutral.grey200
            }
        }

        var textColor: Color {
            switch self {
            case .beforeTaking: return YKColor.Neutral.grey900
            case .taking: return YKColor.Primary.primary400
            case .completed: return YKColor.Neutral.grey500
            }
        }
    }
}

enum MedicineColor: Equatable {
    case purple
    case yellow
    case blue
    case green
    case pink
}
