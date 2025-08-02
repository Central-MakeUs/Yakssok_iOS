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
            let followingResponse: FollowingListResponse = try await APIClient.shared.request(
                endpoint: .getFollowingList,
                method: .GET,
                body: Optional<String>.none
            )

            guard followingResponse.code == 0 else {
                throw APIError.serverError(followingResponse.code)
            }

            var mateCards: [MateCard] = []
            let today = Date()

            for friend in followingResponse.body.followingInfoResponses {
                do {
                    let scheduleResponse: MedicationScheduleResponse = try await APIClient.shared.request(
                        endpoint: .getFriendMedicationSchedulesToday(friend.userId),
                        method: .GET,
                        body: Optional<String>.none
                    )

                    guard scheduleResponse.code == 0 else { continue }

                    let medicineData = scheduleResponse.toMedicineDataResponse()

                    if let status = getMateStatus(medicineData: medicineData) {
                        let card = MateCard(
                            id: "mate_\(friend.userId)",
                            userName: friend.nickName,
                            relationship: friend.relationName,
                            profileImage: friend.profileImageUrl,
                            status: status
                        )
                        mateCards.append(card)
                    }
                } catch {
                    continue
                }
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

private func getMateStatus(medicineData: MedicineDataResponse) -> MateStatus? {
    let totalMedicines = medicineData.todayMedicines.count + medicineData.completedMedicines.count

    // 약이 없으면 카드 안 뜸
    guard totalMedicines > 0 else { return nil }

    // 모든 약을 다 먹었으면 칭찬
    if medicineData.todayMedicines.isEmpty && medicineData.completedMedicines.count > 0 {
        return .completed
    }

    // 안 먹은 약이 있으면 잔소리
    if medicineData.todayMedicines.count > 0 {
        return .missedMedicine(count: medicineData.todayMedicines.count)
    }

    return nil
}
