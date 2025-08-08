//
//  MedicineCategory.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import Foundation
import YakssokDesignSystem
import SwiftUI

struct MedicineCategory: Equatable, Identifiable {
    let id: String
    let name: String
    let iconName: String
    let colorType: CategoryColorType

    enum CategoryColorType: String, CaseIterable {
        case mental = "mental"
        case beauty = "beauty"
        case chronic = "chronic"
        case diet = "diet"
        case pain = "pain"
        case supplement = "supplement"
        case other = "other"

        var textColor: Color {
            switch self {
            case .mental: return YKColor.Sub.purple
            case .beauty: return YKColor.Sub.green
            case .chronic: return YKColor.Sub.blue
            case .diet: return YKColor.Sub.pink
            case .pain: return Color(red: 0.91, green: 0.62, blue: 0.09)
            case .supplement: return Color(red: 0.86, green: 0.49, blue: 0.14)
            case .other: return Color(red: 0.86, green: 0.14, blue: 0.15)
            }
        }

        var backgroundColor: Color {
            switch self {
            case .mental: return Color(red: 0.941, green: 0.890, blue: 1.0)
            case .beauty: return Color(red: 0.882, green: 1.0, blue: 0.894)
            case .chronic: return Color(red: 0.878, green: 0.949, blue: 1.0)
            case .diet: return Color(red: 0.996, green: 0.941, blue: 1.0)
            case .pain: return Color(red: 1.0, green: 0.969, blue: 0.914)
            case .supplement: return Color(red: 1.0, green: 0.922, blue: 0.851)
            case .other: return Color(red: 1.0, green: 0.890, blue: 0.890)
            }
        }
    }

    static let defaultCategories: [MedicineCategory] = [
        MedicineCategory(id: "supplement", name: "건강기능식품/영양보충", iconName: "", colorType: .supplement),
        MedicineCategory(id: "chronic", name: "만성 질환 관리", iconName: "", colorType: .chronic),
        MedicineCategory(id: "beauty", name: "미용 관련 관리", iconName: "", colorType: .beauty),
        MedicineCategory(id: "diet", name: "다이어트/대사 관련", iconName: "", colorType: .diet),
        MedicineCategory(id: "pain", name: "통증/간기 등 일시적 치료", iconName: "", colorType: .pain),
        MedicineCategory(id: "mental", name: "정신 건강 관리", iconName: "", colorType: .mental),
        MedicineCategory(id: "other", name: "기타 설정", iconName: "", colorType: .other)
    ]
}
