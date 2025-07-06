//
//  SplashFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import ComposableArchitecture

struct SplashFeature: Reducer {
    struct State: Equatable {}

    enum Action: Equatable {
        case onAppear
        case isCompleted
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await Task.sleep(for: .seconds(1.5))
                    await send(.isCompleted)
                }
            case .isCompleted:
                return .none
            }
        }
    }
}
