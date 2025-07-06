//
//  HomeFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct HomeFeature: Reducer {
    struct State: Equatable {
    }

    @CasePathable
    enum Action: Equatable {
        case isCompleted
        case calendarTapped
        case notificationTapped
        case menuTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .isCompleted:
                return .none
            case .calendarTapped:
                return .none
            case .notificationTapped:
                return .none
            case .menuTapped:
                return .none
            }
        }
    }
}
