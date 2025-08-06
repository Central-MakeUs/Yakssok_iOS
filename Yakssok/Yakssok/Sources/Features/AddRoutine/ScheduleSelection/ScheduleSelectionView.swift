//
//  ScheduleSelectionView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct ScheduleSelectionView: View {
    let store: StoreOf<ScheduleSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("복용기간을 선택해주세요")
                        .font(YKFont.subtitle2)
                        .foregroundColor(YKColor.Neutral.grey950)

                    DateRangeSelector(store: store)
                }
                .padding(.horizontal, 16)

                Spacer()
                    .frame(height: 32)

                VStack(alignment: .leading, spacing: 20) {
                    Text("요일과 횟수를 설정해주세요")
                        .font(YKFont.subtitle2)
                        .foregroundColor(YKColor.Neutral.grey950)
                        .padding(.horizontal, 16)

                    FrequencySelector(store: store)
                        .padding(.horizontal, 16)
                }

                Spacer()
                    .frame(height: 20)

                TimeSelector(store: store)
                    .padding(.horizontal, 16)

                Spacer()
            }
        }
    }
}

struct FrequencySelector: View {
    let store: StoreOf<ScheduleSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 12) {
                FrequencyButton(
                    title: "매주",
                    subtitle: viewStore.frequencyDisplayText,
                    onTap: { viewStore.send(.showFrequencyModal) }
                )

                Text("/")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey400)

                TimesPerDayButton(
                    title: "하루에",
                    count: viewStore.timesPerDay,
                    onTap: { viewStore.send(.showTimesPerDayModal) }
                )
            }
        }
    }
}

private struct FrequencyButton: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(YKFont.caption1)
                    .foregroundColor(YKColor.Neutral.grey400)

                Text(subtitle)
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey950)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }
}

private struct TimesPerDayButton: View {
    let title: String
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(YKFont.caption1)
                    .foregroundColor(YKColor.Neutral.grey400)

                Text("\(count)번")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey950)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }
}

struct DateRangeSelector: View {
    let store: StoreOf<ScheduleSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 12) {
                DateButton(
                    title: "시작일",
                    date: viewStore.startDate,
                    isEndDateButton: false,
                    hasEndDate: true,
                    onTap: { viewStore.send(.startDateButtonTapped) }
                )

                Text("~")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey400)

                DateButton(
                    title: "종료일",
                    date: viewStore.endDate,
                    isEndDateButton: true,
                    hasEndDate: viewStore.hasEndDate,
                    onTap: { viewStore.send(.endDateButtonTapped) }
                )
            }
        }
    }
}

private struct DateButton: View {
    let title: String
    let date: Date
    let isEndDateButton: Bool
    let hasEndDate: Bool
    let onTap: () -> Void

    private var dateString: String {
        if isEndDateButton && !hasEndDate {
            return "종료일 없음"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(YKFont.caption1)
                    .foregroundColor(YKColor.Neutral.grey400)

                Text(dateString)
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey950)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }
}
