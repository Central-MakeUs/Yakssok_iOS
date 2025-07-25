//
//  SelectionModal.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import YakssokDesignSystem

struct SelectionModal<T: Hashable>: View {
    let title: String
    let items: [SelectionItem<T>]
    let selectedItem: T?
    let onSelect: (T) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 모달 핸들
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 37, height: 4)
                .cornerRadius(2)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // 제목
            Text(title)
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey950)
                .padding(.bottom, 32)

            // 선택 항목들
            SelectionGrid(
                items: items,
                selectedItem: selectedItem,
                onSelect: onSelect
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 60)

            // 하단 버튼들
            HStack(spacing: 8) {
                Button("닫기") {
                    onDismiss()
                }
                .frame(width: 84, height: 56)
                .background(YKColor.Neutral.grey100)
                .foregroundColor(YKColor.Neutral.grey400)
                .cornerRadius(16)

                Button("선택") {
                    onDismiss()
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(YKColor.Primary.primary400)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

struct SelectionItem<T: Hashable> {
    let value: T
    let displayText: String
}

private struct SelectionGrid<T: Hashable>: View {
    let items: [SelectionItem<T>]
    let selectedItem: T?
    let onSelect: (T) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                SelectionButton(
                    text: item.displayText,
                    isSelected: selectedItem == item.value,
                    onTap: { onSelect(item.value) }
                )
            }
        }
    }
}

private struct SelectionButton: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(YKFont.subtitle2)
                .foregroundColor(isSelected ? YKColor.Primary.primary400 : YKColor.Neutral.grey400)
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(isSelected ? YKColor.Primary.primary50 : YKColor.Neutral.grey100)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? YKColor.Primary.primary400 : Color.clear, lineWidth: 2)
                        )
                )
        }
    }
}
