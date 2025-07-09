//
//  MateCardsFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import ComposableArchitecture

struct MateCardsFeature: Reducer {
    struct State: Equatable {
        var cards: [MateCard] = []
        var isLoading: Bool = false
        var error: String?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case cardTapped(id: String)
        case loadCards
        case cardsLoaded([MateCard])
        case loadingFailed(String)
    }

    @Dependency(\.mateCardsClient) var mateCardsClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadCards)
            case .loadCards:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let cards = try await mateCardsClient.loadCards()
                        await send(.cardsLoaded(cards))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
            case .cardTapped(let cardId):
                // TODO: 메시지 보내기 기능 구현
                return .none
            case .cardsLoaded(let cards):
                state.cards = cards
                state.isLoading = false
                return .none
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
            }
        }
    }
}
