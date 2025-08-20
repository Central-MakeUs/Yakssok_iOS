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
        var cardToDelete: String? = nil
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case cardTapped(id: String)
        case loadCards
        case cardsLoaded([MateCard])
        case messageWasSent(targetUserId: String)
        case startCardDeletion(id: String)
        case completeCardDeletion
        case delegate(Delegate)

        enum Delegate: Equatable {
            case showMessageModal(targetUser: String, targetUserId: Int, messageType: MessageType)
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

                guard let userId = Int(cardId) else {
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
                    targetUserId: userId,
                    messageType: messageType
                )))

            case .cardsLoaded(let cards):
                state.cards = cards
                return .none

            case .messageWasSent(let targetUserId):
                return .send(.startCardDeletion(id: targetUserId))

            case .startCardDeletion(let cardId):
                state.cardToDelete = cardId
                return .run { send in
                    try await Task.sleep(for: .milliseconds(600))
                    await send(.completeCardDeletion)
                }

            case .completeCardDeletion:
                if let cardToDelete = state.cardToDelete {
                    state.cards.removeAll { $0.id == cardToDelete }
                    state.cardToDelete = nil
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
