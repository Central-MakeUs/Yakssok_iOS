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
                    }
                }
            }
        }
    }
}
