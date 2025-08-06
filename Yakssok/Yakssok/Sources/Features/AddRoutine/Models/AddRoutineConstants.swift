//
//  AddRoutineConstants.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import Foundation

enum AddRoutineConstants {
    static let maxMedicineNameLength = 15
    static let totalSteps = 3
    static let stepImagePrefix = "step"

    enum StepTitle {
        static let categoryQuestion = "약 종류를 선택해주세요"
    }

    enum Placeholder {
        static let medicineName = "오메가 3, 유산균 등"
    }

    enum ButtonTitle {
        static let next = "다음"
        static let complete = "완료"
        static let close = "닫기"
    }

    enum Layout {
        static let stepIndicatorSpacing: CGFloat = 8
        static let stepIndicatorSize: CGFloat = 22
        static let categoryButtonSpacing: CGFloat = 12
        static let categoryDotSize: CGFloat = 12
        static let textFieldCornerRadius: CGFloat = 16
        static let categoryButtonCornerRadius: CGFloat = 12
        static let nextButtonCornerRadius: CGFloat = 16
        static let nextButtonHeight: CGFloat = 56
    }
}
