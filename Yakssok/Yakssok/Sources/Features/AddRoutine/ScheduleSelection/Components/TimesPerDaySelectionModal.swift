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
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)

                        Text("하루에 먹을 횟수를 선택해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                            .padding(.bottom, 20)
                            .padding(.top, 28)

                        // 횟수 선택 버튼들
                        VStack(alignment: .leading) {
                            HStack(spacing: 4) {
                                ForEach(1...3, id: \.self) { count in
                                    TimesButton(
                                        count: count,
                                        isSelected: selectedTimes == count,
                                        onTap: { selectedTimes = count }
                                    )
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 60)

                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.dismissTimesPerDayModal)
                            }
                            .font(YKFont.subtitle2)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey500)
                            .cornerRadius(16)

                            Button("선택") {
                                viewStore.send(.timesSelected(selectedTimes))
                            }
                            .font(YKFont.subtitle2)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Primary.primary400)
                            .foregroundColor(YKColor.Neutral.grey50)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(YKColor.Neutral.grey50)
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
                .frame(width: 48, height: 48)
                .background(isSelected ? YKColor.Primary.primary100 : YKColor.Neutral.grey100)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.5)
                        .stroke(isSelected ? YKColor.Primary.primary400 : Color.clear, lineWidth: 1)
                )
        }
    }
}
