//
//  MateCardsClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import ComposableArchitecture
import Foundation

struct MateCardsClient {
    var loadCards: () async throws -> [MateCard]
}

extension MateCardsClient: DependencyKey {
    static let liveValue = Self(
        loadCards: {
            let response: FriendsMedicationStatusResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getFriendsMedicationStatus,
                method: .GET,
                body: Optional<String>.none
            )

            guard response.code == 0 else {
                throw APIError.serverError(response.code)
            }

            let mateCards = response.body.followingMedicationStatusResponses.compactMap { friendStatus in
                return friendStatus.toMateCard()
            }

            return mateCards
        }
    )
}

extension DependencyValues {
    var mateCardsClient: MateCardsClient {
        get { self[MateCardsClient.self] }
        set { self[MateCardsClient.self] = newValue }
    }
}
