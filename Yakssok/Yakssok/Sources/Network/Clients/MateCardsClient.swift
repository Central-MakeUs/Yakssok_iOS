//
//  MateCardsClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import ComposableArchitecture

struct MateCardsClient {
    var loadCards: () async throws -> [MateCard]
}

extension MateCardsClient: DependencyKey {
    static let liveValue = Self(
        loadCards: {
            // TODO: 실제 API 구현
            // 테스트: 3가지 상태 중 하나 선택해서 테스트: empty, sample, many
            return MockMateCardData.cards(for: .sample)
        }
    )
}

extension DependencyValues {
    var mateCardsClient: MateCardsClient {
        get { self[MateCardsClient.self] }
        set { self[MateCardsClient.self] = newValue }
    }
}
