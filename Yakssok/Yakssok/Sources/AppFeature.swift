//
//  AppFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/3/25.
//

import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
    }

    enum Action: Equatable {
        case viewAppeared
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .none
            }
        }
    }
}
