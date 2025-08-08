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
