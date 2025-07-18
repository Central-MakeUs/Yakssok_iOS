//
//  AddRoutineContainerView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct AddRoutineContainerView<Content: View>: View {
    let currentStep: Int
    let isNextButtonEnabled: Bool
    let onBackTapped: () -> Void
    let onNextTapped: () -> Void
    let nextButtonTitle: String
    @ViewBuilder let content: Content
    
    var body: some View {
        NavigationView {
            YKNavigationBar(
                title: "",
                hasBackButton: true,
                onBackTapped: onBackTapped
            ) {
                VStack(spacing: 0) {
                    StepIndicatorView(currentStep: currentStep)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        .padding(.leading, 16)
                    
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                    
                    NextButton(
                        title: nextButtonTitle,
                        isEnabled: isNextButtonEnabled,
                        action: onNextTapped
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(YKColor.Neutral.grey100)
            }
        }
        .navigationBarHidden(true)
    }
}
