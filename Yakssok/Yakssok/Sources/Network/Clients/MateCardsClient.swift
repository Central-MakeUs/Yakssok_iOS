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
            let followingResponse: FollowingListResponse = try await APIClient.shared.requestWithTokenRefresh(
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
                    let scheduleResponse: MedicationScheduleResponse = try await APIClient.shared.requestWithTokenRefresh(
                        endpoint: .getFriendMedicationSchedulesToday(friend.userId),
                        method: .GET,
                        body: Optional<String>.none
                    )

                    guard scheduleResponse.code == 0 else { continue }

                    let medicineData = scheduleResponse.toMedicineDataResponse()

                    // 현재 시간 기준으로 약 재분류
                    let missedMedicines = medicineData.todayMedicines.filter { medicine in
                        isMedicineTimePassedForToday(medicineTime: medicine.time, currentTime: today)
                    }

                    if let status = getMateStatusWithMissedCount(
                        missedMedicines: missedMedicines,
                        completedMedicines: medicineData.completedMedicines
                    ) {
                        let card = MateCard(
                            id: String(friend.userId),
                            userName: friend.nickName,
                            relationship: friend.relationName,
                            profileImage: friend.profileImageUrl,
                            status: status,
                            todayMedicines: missedMedicines, // 시간 지났는데 안 먹은 약
                            completedMedicines: medicineData.completedMedicines
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

/// 놓친 약 개수를 직접 받아서 계산
private func getMateStatusWithMissedCount(
    missedMedicines: [Medicine],
    completedMedicines: [Medicine]
) -> MateStatus? {
    let totalMedicines = missedMedicines.count + completedMedicines.count

    // 약이 없으면 카드 안 뜨게 함
    guard totalMedicines > 0 else { return nil }

    // 놓친 약이 있으면 잔소리
    if missedMedicines.count > 0 {
        return .missedMedicine(count: missedMedicines.count)
    }

    // 놓친 약이 없고 완료된 약이 있으면 칭찬
    if completedMedicines.count > 0 {
        return .completed
    }

    return nil // 놓친 약도 없고 완료된 약도 없으면 카드 안 뜨게 함
}

/// 오늘 날짜에서 특정 약의 복용 시간이 현재 시간을 넘었는지 확인
private func isMedicineTimePassedForToday(medicineTime: String, currentTime: Date) -> Bool {
    guard let medicineDate = convertMedicineTimeToDate(medicineTime: medicineTime, baseDate: currentTime) else {
        return false
    }

    return medicineDate <= currentTime
}

/// Medicine의 time 문자열을 Date로 변환 (오늘 날짜 기준)
private func convertMedicineTimeToDate(medicineTime: String, baseDate: Date) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "a h:mm"

    // 문자열을 시간으로 파싱
    guard let timeOnly = formatter.date(from: medicineTime) else {
        return nil
    }

    let calendar = Calendar.current
    let timeComponents = calendar.dateComponents([.hour, .minute], from: timeOnly)

    // 오늘 날짜의 해당 시간으로 변환
    guard let todayAtMedicineTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                  minute: timeComponents.minute ?? 0,
                                                  second: 0,
                                                  of: baseDate) else {
        return nil
    }

    return todayAtMedicineTime
}
