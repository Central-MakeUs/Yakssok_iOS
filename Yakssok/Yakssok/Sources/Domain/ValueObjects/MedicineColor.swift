//
//  MedicineColor.swift
//  Yakssok
//
//  Created by 김사랑 on 7/26/25.
//

import SwiftUI
import YakssokDesignSystem

enum MedicineColor: Equatable {
    case purple
    case yellow
    case blue
    case green
    case pink
    case orange
    case red
}

extension MedicineColor {
    var colorValue: Color {
        switch self {
        case .purple: return YKColor.Sub.purple
        case .blue: return YKColor.Sub.blue
        case .green: return YKColor.Sub.green
        case .pink: return YKColor.Sub.pink
        case .yellow: return Color(red: 0.91, green: 0.62, blue: 0.09)
        case .orange: return Color(red: 0.86, green: 0.49, blue: 0.14)
        case .red: return Color(red: 0.86, green: 0.14, blue: 0.15)
        }
    }
}
