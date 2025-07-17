//
//  FrequencySelectorModal.swift
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
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        Text("복용주기를 선택해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                            .padding(.bottom, 20)
                            .padding(.top, 16)

                        // 요일 선택 버튼들
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
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
                                    .font(YKFont.body1)
                                    .foregroundColor(YKColor.Neutral.grey950)

                                Button(action: {
                                    isDaily.toggle()
                                    if isDaily {
                                        selectedWeekdays = Set(Weekday.allCases)
                                    } else {
                                        selectedWeekdays.removeAll()
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(isDaily ? YKColor.Neutral.grey800 : YKColor.Neutral.grey100)
                                            .frame(width: 24, height: 24)
                                            .cornerRadius(6.57)
                                        Image(isDaily ? "check-yes" : "check-no")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 40)
                        }


                        Spacer()
                            .frame(height: 60)

                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.dismissFrequencyModal)
                            }
                            .font(YKFont.subtitle2)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey500)
                            .cornerRadius(16)

                            Button("선택") {
                                let frequency: ScheduleSelectionFeature.State.FrequencyType = isDaily ? .daily : .weekly
                                viewStore.send(.frequencySelected(frequency, selectedWeekdays))
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
