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
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case cardTapped(id: String)
        case loadCards
        case cardsLoaded([MateCard])
        case delegate(Delegate)

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
                return .run { send in
                    do {
                        let cards = try await mateCardsClient.loadCards()
                        await send(.cardsLoaded(cards))
                    } catch {
                        await send(.cardsLoaded([]))
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
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
