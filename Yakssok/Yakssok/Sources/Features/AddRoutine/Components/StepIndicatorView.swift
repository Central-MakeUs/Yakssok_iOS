//
//  StepIndicatorView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct StepIndicatorView: View {
    let currentStep: Int

    var body: some View {
        HStack(spacing: AddRoutineConstants.Layout.stepIndicatorSpacing) {
            ForEach(1...AddRoutineConstants.totalSteps, id: \.self) { step in
                StepIndicatorItem(
                    step: step,
                    isCurrent: step == currentStep
                )
            }
            Spacer()
        }
    }
}

struct StepIndicatorItem: View {
    let step: Int
    let isCurrent: Bool

    var body: some View {
        Image(stepImageName)
            .resizable()
            .frame(
                width: AddRoutineConstants.Layout.stepIndicatorSize,
                height: AddRoutineConstants.Layout.stepIndicatorSize
            )
    }

    private var stepImageName: String {
        let stepNumber = String(format: "%02d", step)
        let suffix = isCurrent ? "fill" : "grey"
        return "\(AddRoutineConstants.stepImagePrefix)\(stepNumber)-\(suffix)"
    }
}
