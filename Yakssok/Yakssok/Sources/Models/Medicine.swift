//
//  Medicine.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import Foundation

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
}

enum MedicineColor: Equatable {
    case purple
    case yellow
    case blue
    case green
    case pink
}
