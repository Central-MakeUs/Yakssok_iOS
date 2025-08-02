//
//  MateCard.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import Foundation

struct MateCard: Identifiable, Equatable {
    let id: String
    let userName: String
    let relationship: String
    let profileImage: String?
    let status: MateStatus
    let todayMedicines: [Medicine]
    let completedMedicines: [Medicine]
}

enum MateStatus: Equatable {
    case missedMedicine(count: Int)
    case completed
}
