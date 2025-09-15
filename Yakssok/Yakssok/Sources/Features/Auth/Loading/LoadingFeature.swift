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
        var authorizationCode: String
        var oauthType: String = ""
        var identityToken: String? // Apple 로그인용
        var isRegistering: Bool = false

        var currentIconName: String {
            return "loading-\(currentIconIndex + 1)"
        }

        init(nickname: String, authorizationCode: String, oauthType: String = "kakao", identityToken: String? = nil) {
            self.nickname = nickname
            self.authorizationCode = authorizationCode
            self.oauthType = oauthType
            self.identityToken = identityToken
        }
    }

    enum Action: Equatable {
        case onAppear
        case timerTicked
        case registrationCompleted
        case registrationFailed(String)
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isRegistering else { return .none }
                state.isRegistering = true

                return .run { send in
                    for await _ in clock.timer(interval: .milliseconds(500)) {
                        await send(.timerTicked)
                    }
                }
                .cancellable(id: "iconTimer")


            case .timerTicked:
                state.currentIconIndex = (state.currentIconIndex + 1) % 5
                return .none

            case .registrationCompleted:
                state.isRegistering = false
                return .cancel(id: "iconTimer")

            case .registrationFailed:
                state.isRegistering = false
                return .cancel(id: "iconTimer")
            }
        }
    }
}
