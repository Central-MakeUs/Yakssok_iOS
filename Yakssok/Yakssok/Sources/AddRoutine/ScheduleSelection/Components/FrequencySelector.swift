//
//  FrequencySelector.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct FrequencySelectionModal: View {
    let store: StoreOf<ScheduleSelectionFeature>
    @State private var selectedWeekdays: Set<Weekday> = Set(Weekday.allCases)
    @State private var isDaily: Bool = true

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.dismissFrequencyModal)
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
                        Text("복용주기를 선택해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey950)
                            .padding(.bottom, 40)

                        // 요일 선택 버튼들
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ForEach([Weekday.monday, .tuesday, .wednesday, .thursday, .friday, .saturday], id: \.self) { weekday in
                                    WeekdayButton(
                                        weekday: weekday,
                                        isSelected: selectedWeekdays.contains(weekday),
                                        onTap: {
                                            if selectedWeekdays.contains(weekday) {
                                                selectedWeekdays.remove(weekday)
                                            } else {
                                                selectedWeekdays.insert(weekday)
                                            }
                                            // 매일 체크박스 상태 업데이트
                                            isDaily = selectedWeekdays.count == 7
                                        }
                                    )
                                }
                            }

                            HStack {
                                WeekdayButton(
                                    weekday: .sunday,
                                    isSelected: selectedWeekdays.contains(.sunday),
                                    onTap: {
                                        if selectedWeekdays.contains(.sunday) {
                                            selectedWeekdays.remove(.sunday)
                                        } else {
                                            selectedWeekdays.insert(.sunday)
                                        }
                                        // 매일 체크박스 상태 업데이트
                                        isDaily = selectedWeekdays.count == 7
                                    }
                                )
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)

                        // 매일 체크박스
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Text("매일")
                                    .font(YKFont.body2)
                                    .foregroundColor(YKColor.Neutral.grey400)

                                Button(action: {
                                    isDaily.toggle()
                                    if isDaily {
                                        selectedWeekdays = Set(Weekday.allCases)
                                    } else {
                                        selectedWeekdays.removeAll()
                                    }
                                }) {
                                    Image(systemName: isDaily ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isDaily ? YKColor.Primary.primary400 : YKColor.Neutral.grey300)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 40)
                        }

                        Spacer()
                            .frame(height: 60)

                        // 버튼들
                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.dismissFrequencyModal)
                            }
                            .frame(width: 84, height: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey400)
                            .cornerRadius(16)

                            Button("선택") {
                                let frequency: ScheduleSelectionFeature.State.FrequencyType = isDaily ? .daily : .weekly
                                viewStore.send(.frequencySelected(frequency, selectedWeekdays))
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
                selectedWeekdays = viewStore.selectedWeekdays
                isDaily = viewStore.frequencyType == .daily
            }
        }
    }
}

struct WeekdayButton: View {
    let weekday: Weekday
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(weekday.shortName)
                .font(YKFont.subtitle2)
                .foregroundColor(isSelected ? YKColor.Primary.primary400 : YKColor.Neutral.grey400)
                .frame(width: 44, height: 44)
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
