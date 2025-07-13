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
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case showMessageModal(targetUser: String, messageType: MessageType)
        }
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
                guard let card = state.cards.first(where: { $0.id == cardId }) else {
                    return .none
                }
                let messageType: MessageType = {
                    switch card.status {
                    case .missedMedicine:
                        return .nagging
                    case .completed:
                        return .encouragement
                    }
                }()
                return .send(.delegate(.showMessageModal(
                    targetUser: card.userName,
                    messageType: messageType
                )))
            case .cardsLoaded(let cards):
                state.cards = cards
                state.isLoading = false
                return .none
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}
