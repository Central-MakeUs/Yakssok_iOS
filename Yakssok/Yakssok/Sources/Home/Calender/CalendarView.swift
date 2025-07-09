//
//  CalendarView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct CalendarView: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.headerToCalendarSpacing) {
                HeaderView(store: store)
                CalendarContentView(store: store)
            }
            .padding(.horizontal, Layout.horizontalPadding)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private struct HeaderView: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                MonthYearText(monthYear: viewStore.currentMonthYear)
                Spacer()
                CalendarButton {
                    viewStore.send(.calendarButtonTapped)
                }
            }
        }
    }
}

private struct MonthYearText: View {
    let monthYear: String

    var body: some View {
        Text(monthYear)
            .font(YKFont.body1)
            .foregroundColor(YKColor.Neutral.grey950)
    }
}

private struct CalendarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.calendarButtonSpacing) {
                Text("캘린더")
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey400)
                Image(systemName: "chevron.right")
                    .font(.system(size: Layout.chevronSize, weight: .bold))
                    .foregroundColor(YKColor.Neutral.grey400)
                    .padding(.trailing, Layout.chevronTrailingPadding)
            }
        }
    }
}

private struct CalendarContentView: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.weekdayToDateSpacing) {
                WeekdayHeaderView(store: store)
                WeekDatesView(store: store)
            }
            .padding(.vertical, Layout.calendarVerticalPadding)
            .background(SelectedColumnBackground(store: store))
        }
    }
}

private struct WeekdayHeaderView: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: Layout.itemSpacing) {
                ForEach(Array(Layout.weekdays.enumerated()), id: \.offset) { index, weekday in
                    WeekdayText(
                        weekday: weekday,
                        isSelected: isWeekdaySelected(index: index, viewStore: viewStore)
                    )
                }
            }
        }
    }

    private func isWeekdaySelected(index: Int, viewStore: ViewStoreOf<CalendarFeature>) -> Bool {
        guard index < viewStore.currentWeekDates.count else { return false }
        return Calendar.current.isDate(viewStore.currentWeekDates[index], inSameDayAs: viewStore.selectedDate)
    }
}

private struct WeekdayText: View {
    let weekday: String
    let isSelected: Bool

    var body: some View {
        Text(weekday)
            .font(YKFont.body1)
            .foregroundColor(isSelected ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400)
            .frame(maxWidth: .infinity, minHeight: Layout.weekdayHeight)
    }
}

private struct WeekDatesView: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: Layout.itemSpacing) {
                ForEach(viewStore.currentWeekDates, id: \.self) { date in
                    DateButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewStore.selectedDate)
                    ) {
                        viewStore.send(.dateSelected(date))
                    }
                }
            }
        }
    }
}

private struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: action) {
            Text(dayString)
                .font(YKFont.subtitle2)
                .foregroundColor(isSelected ? YKColor.Neutral.grey50 : YKColor.Neutral.grey600)
                .frame(maxWidth: .infinity, minHeight: Layout.dateHeight)
        }
    }
}

private struct SelectedColumnBackground: View {
    let store: StoreOf<CalendarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: Layout.itemSpacing) {
                ForEach(Array(viewStore.currentWeekDates.enumerated()), id: \.offset) { index, date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: viewStore.selectedDate)

                    RoundedRectangle(cornerRadius: Layout.backgroundCornerRadius)
                        .fill(isSelected ? YKColor.Neutral.grey900 : Color.clear)
                        .frame(maxWidth: .infinity, minHeight: Layout.backgroundHeight)
                }
            }
        }
    }
}

private enum Layout {
    // 상수들
    static let horizontalPadding: CGFloat = 16
    static let headerToCalendarSpacing: CGFloat = 13.5
    static let weekdayToDateSpacing: CGFloat = 8
    static let calendarVerticalPadding: CGFloat = 8
    static let itemSpacing: CGFloat = 0

    // 크기
    static let weekdayHeight: CGFloat = 24
    static let dateHeight: CGFloat = 24
    static let backgroundHeight: CGFloat = 8 + 24 + 8 + 24 + 8 // 총 72pt
    static let backgroundCornerRadius: CGFloat = 8

    // 버튼 관련
    static let calendarButtonSpacing: CGFloat = 4
    static let chevronSize: CGFloat = 12
    static let chevronTrailingPadding: CGFloat = 4

    // 데이터
    static let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
}
