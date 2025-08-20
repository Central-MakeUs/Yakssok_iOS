//
//  MateCardsView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MateCardsView: View {
    let store: StoreOf<MateCardsFeature>

    private let cardSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(Array(viewStore.cards.enumerated()), id: \.element.id) { index, card in
                        MateCardItemView(card: card) {
                            viewStore.send(.cardTapped(id: card.id))
                        }
                        .padding(.leading, index == 0 ? horizontalPadding : 0)
                        .padding(.trailing, index == viewStore.cards.count - 1 ? horizontalPadding : 0)
                        .offset(y: cardDeleteOffset(for: card.id, viewStore: viewStore))
                        .opacity(cardDeleteOpacity(for: card.id, viewStore: viewStore))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: viewStore.cardToDelete)
                    }
                }
            }
        }
    }

    // 카드 삭제 애니메이션
    private func cardDeleteOffset(for cardId: String, viewStore: ViewStore<MateCardsFeature.State, MateCardsFeature.Action>) -> CGFloat {
        guard let cardToDelete = viewStore.cardToDelete, cardToDelete == cardId else {
            return 0
        }
        // 위로 슝 날아가게
        return -200
    }

    private func cardDeleteScale(for cardId: String, viewStore: ViewStore<MateCardsFeature.State, MateCardsFeature.Action>) -> CGFloat {
        return 1.0
    }

    private func cardDeleteOpacity(for cardId: String, viewStore: ViewStore<MateCardsFeature.State, MateCardsFeature.Action>) -> Double {
        guard let cardToDelete = viewStore.cardToDelete, cardToDelete == cardId else {
            return 1.0
        }
        return 0.3
    }
}
