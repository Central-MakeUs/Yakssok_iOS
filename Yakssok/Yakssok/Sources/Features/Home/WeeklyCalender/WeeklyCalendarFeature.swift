//
//  CalendarFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import ComposableArchitecture
import Foundation

struct WeeklyCalendarFeature: Reducer {
    struct State: Equatable {
        var selectedDate: Date = Date()
        var currentWeekDates: [Date] = []
        var currentMonthYear: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: selectedDate)
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case dateSelected(Date)
        case calendarButtonTapped
        case weekDatesCalculated([Date])
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case showFullCalendar
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.weekDatesCalculated(getCurrentWeekDates()))
            case .dateSelected(let date):
                state.selectedDate = date
                return .none
            case .calendarButtonTapped:
                return .send(.delegate(.showFullCalendar))
            case .weekDatesCalculated(let dates):
                state.currentWeekDates = dates
                return .none
            case .delegate:
                return .none
            }
        }
    }

    private func getCurrentWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7

        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
}
