//
//  TimesPerDaySelectionModal.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct TimesPerDaySelectionModal: View {
    let store: StoreOf<ScheduleSelectionFeature>
    @State private var selectedTimes: Int = 1

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.dismissTimesPerDayModal)
                    }

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        // 핸들바
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 37, height: 4)
                            .cornerRadius(2)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        // 제목
                        Text("하루에 먹을 횟수를 선택해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey950)
                            .padding(.bottom, 40)

                        // 횟수 선택 버튼들
                        HStack(spacing: 16) {
                            ForEach(1...3, id: \.self) { count in
                                TimesButton(
                                    count: count,
                                    isSelected: selectedTimes == count,
                                    onTap: { selectedTimes = count }
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 120)

                        // 버튼들
                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.dismissTimesPerDayModal)
                            }
                            .frame(width: 84, height: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey400)
                            .cornerRadius(16)

                            Button("선택") {
                                viewStore.send(.timesSelected(selectedTimes))
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
                    .cornerRadius(24)
                    .padding(.horizontal, 13.5)
                }
            }
            .onAppear {
                selectedTimes = viewStore.timesPerDay
            }
        }
    }
}

struct TimesButton: View {
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(count)")
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
