//
//  TimeSelector.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct TimeSelector: View {
    let store: StoreOf<ScheduleSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                ForEach(0..<viewStore.timesPerDay, id: \.self) { index in
                    TimeSlotView(
                        index: index,
                        time: viewStore.selectedTimes[safe: index] ?? MedicineTime(hour: 8, minute: 0),
                        onTap: { viewStore.send(.showTimePickerModal(index)) }
                    )
                }
            }
        }
    }
}

private struct TimeSlotView: View {
    let index: Int
    let time: MedicineTime
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("\(index + 1)번째")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey400)

                Spacer()

                HStack(spacing: 8) {
                    Text(time.timeString)
                        .font(YKFont.subtitle2)
                        .foregroundColor(YKColor.Neutral.grey700)

                    // 위아래 화살표 아이콘 추가
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(YKColor.Neutral.grey400)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(YKColor.Neutral.grey400)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }
}

// Array 안전 접근을 위한 extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
