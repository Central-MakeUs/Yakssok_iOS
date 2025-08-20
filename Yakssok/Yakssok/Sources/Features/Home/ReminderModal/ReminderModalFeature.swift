//
//  ReminderModalFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture
import Foundation

struct ReminderModalFeature: Reducer {
    struct State: Equatable {
        let userName: String
        let missedMedicines: [Medicine]

        var shouldScroll: Bool {
            missedMedicines.count > 5
        }
    }

    @CasePathable
    enum Action: Equatable {
        case takeMedicineNowTapped
        case closeButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismissed
            case navigateToHome
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .takeMedicineNowTapped:
                return .send(.delegate(.navigateToHome))

            case .closeButtonTapped:
                return .send(.delegate(.dismissed))

            case .delegate:
                return .none
            }
        }
    }
}

extension ReminderModalFeature {
    /// 놓친 약을 찾는 함수
    static func getMissedMedicines(from medicineData: MedicineDataResponse) -> [Medicine] {
        let now = Date()
        let calendar = Calendar.current

        // 오늘이 아니면 놓친 약 없음
        let today = Date()
        guard calendar.isDate(today, inSameDayAs: today) else {
            return []
        }

        return medicineData.todayMedicines.compactMap { medicine in
            guard let medicineTime = parseMedicineTime(medicine.time) else {
                return nil
            }

            // 현재 시간이 복약 시간을 30분 이상 지났으면 놓친 약
            let timeDifference = now.timeIntervalSince(medicineTime)
            let missedThreshold: TimeInterval = 30 * 60 // 30분

            return timeDifference > missedThreshold ? medicine : nil
        }
    }

    /// 복약 시간 문자열을 Date로 변환
    private static func parseMedicineTime(_ timeString: String) -> Date? {
        let now = Date()
        let calendar = Calendar.current

        // "오전 9:00" 또는 "오후 2:30" 형태를 파싱
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"

        guard let time = formatter.date(from: timeString) else {
            return nil
        }

        // 오늘 날짜에 해당 시간을 적용
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        var combinedComponents = DateComponents()
        combinedComponents.year = todayComponents.year
        combinedComponents.month = todayComponents.month
        combinedComponents.day = todayComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        return calendar.date(from: combinedComponents)
    }
}
