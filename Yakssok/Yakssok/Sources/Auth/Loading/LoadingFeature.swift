//
//  LoadingFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/25/25.
//

import ComposableArchitecture
import Foundation

struct LoadingFeature: Reducer {
    struct State: Equatable {
        var currentIconIndex: Int = 0
        var nickname: String

        var currentIconName: String {
            return "loading-\(currentIconIndex + 1)"
        }
    }

    enum Action: Equatable {
        case onAppear
        case timerTicked
        case registrationCompleted
        case registrationFailed(String)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.userRegistrationClient) var userRegistrationClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        for await _ in clock.timer(interval: .milliseconds(500)) {
                            await send(.timerTicked)
                        }
                    },
                    .run { [nickname = state.nickname] send in
                        do {
                            try await userRegistrationClient.registerUser(nickname)
                            try await clock.sleep(for: .seconds(2))
                            await send(.registrationCompleted)
                        } catch {
                            await send(.registrationFailed(error.localizedDescription))
                        }
                    }
                )

            case .timerTicked:
                state.currentIconIndex = (state.currentIconIndex + 1) % 5
                return .none

            case .registrationCompleted:
                return .none

            case .registrationFailed:
                return .none
            }
        }
    }
}
