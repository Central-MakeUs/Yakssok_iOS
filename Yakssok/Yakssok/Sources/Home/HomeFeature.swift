//
//  HomeFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import Foundation
import ComposableArchitecture

struct HomeFeature: Reducer {
    struct State: Equatable {
        var currentUser: User?
        var selectedDate: Date = Date()
        var userSelection: MateSelectionFeature.State? = .init()
        var mateCards: MateCardsFeature.State? = .init()
        var calendar: CalendarFeature.State? = .init()
        var shouldShowMateCards: Bool {
            mateCards?.cards.isEmpty == false
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case calendarTapped
        case notificationTapped
        case menuTapped
        case userSelection(MateSelectionFeature.Action)
        case mateCards(MateCardsFeature.Action)
        case calendar(CalendarFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.mateCards(.onAppear)),
                    .send(.calendar(.onAppear))
                )
            case .calendarTapped:
                // TODO: 캘린더 화면 이동
                return .none
            case .notificationTapped:
                // TODO: 알람 화면 이동
                return .none
            case .menuTapped:
                // TODO: 메뉴 화면 이동
                return .none
            case .userSelection, .mateCards, .calendar:
                return .none
            }
        }
        .ifLet(\.userSelection, action: \.userSelection) {
            MateSelectionFeature()
        }
        .ifLet(\.mateCards, action: \.mateCards) {
            MateCardsFeature()
        }
        .ifLet(\.calendar, action: \.calendar) {
            CalendarFeature()
        }
    }
}
