//
//  MedicineNameTextField.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct MedicineNameTextField: View {
    @Binding var text: String
    let placeholder: String
    let characterCount: String
    let onTextChanged: (String) -> Void

    var body: some View {
        ZStack {
            placeholderView
            inputFieldView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(YKColor.Neutral.grey50)
        .cornerRadius(AddRoutineConstants.Layout.textFieldCornerRadius)
    }

    private var placeholderView: some View {
        Group {
            if text.isEmpty {
                HStack {
                    Text(placeholder)
                        .font(YKFont.body1)
                        .foregroundColor(YKColor.Neutral.grey400)
                    Spacer()
                }
            }
        }
    }

    private var inputFieldView: some View {
        HStack {
            textField
            counterAndClearButton
        }
    }

    private var textField: some View {
        TextField("", text: $text)
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > AddRoutineConstants.maxMedicineNameLength {
                    text = String(newValue.prefix(AddRoutineConstants.maxMedicineNameLength))
                }
                onTextChanged(text)
            }
            .font(YKFont.body2)
            .foregroundColor(YKColor.Neutral.grey950)
    }

    private var counterAndClearButton: some View {
        HStack(spacing: 12) {
            Text(characterCount)
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey300)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onTextChanged("")
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(YKColor.Neutral.grey500)
                }
            }
        }
    }
}
