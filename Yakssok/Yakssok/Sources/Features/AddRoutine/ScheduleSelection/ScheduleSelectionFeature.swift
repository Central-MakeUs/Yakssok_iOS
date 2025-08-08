//
//  ScheduleSelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture
import Foundation

struct ScheduleSelectionFeature: Reducer {
    struct State: Equatable {
        var startDate: Date = Date()
        var endDate: Date = Date()
        var hasEndDate: Bool = true // 종료일 없음 체크박스 상태
        var showDatePicker: Bool = false
        var isSelectingStartDate: Bool = true
        var frequencyType: FrequencyType = .daily
        var selectedWeekdays: Set<Weekday> = Set(Weekday.allCases) // 매일이 디폴트
        var timesPerDay: Int = 1
        var selectedTimes: [MedicineTime] = [MedicineTime(hour: 8, minute: 0)] // 기본 오전 8:00
        var showFrequencyModal: Bool = false
        var showTimesPerDayModal: Bool = false
        var showTimePickerModal: Bool = false
        var selectedTimeIndex: Int = 0
        var tempTime: MedicineTime = MedicineTime(hour: 8, minute: 0)

        // 모달 플로우 상태 추가
        var hasSelectedStartDate: Bool = false
        var hasSelectedEndDate: Bool = false
        var hasSelectedFrequency: Bool = false
        var hasSelectedTimes: Bool = false

        var isNextButtonEnabled: Bool {
            return !selectedTimes.isEmpty
        }

        // 요일 표시 텍스트
        var frequencyDisplayText: String {
            if selectedWeekdays.count == 7 {
                return "매일"
            } else if selectedWeekdays.isEmpty {
                return "요일 선택"
            } else {
                let sortedWeekdays = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }
                return sortedWeekdays.map { $0.shortName }.joined(separator: ", ")
            }
        }

        enum FrequencyType: Equatable {
            case daily
            case weekly
        }
    }

    @CasePathable
    enum Action: Equatable {
        case startDateButtonTapped
        case endDateButtonTapped
        case datePickerDismissed
        case dateChanged(Date)
        case endDateToggled
        case frequencyTypeChanged(State.FrequencyType)
        case weekdayToggled(Weekday)
        case timesPerDayChanged(Int)
        case timeButtonTapped(Int)
        case timeChanged(Int, MedicineTime)
        case showFrequencyModal
        case showTimesPerDayModal
        case dismissFrequencyModal
        case dismissTimesPerDayModal
        case frequencySelected(State.FrequencyType, Set<Weekday>)
        case timesSelected(Int)
        case nextButtonTapped
        case showTimePickerModal(Int)
        case dismissTimePickerModal
        case tempTimeChanged(MedicineTime)
        case confirmTimeSelection
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startDateButtonTapped:
                state.isSelectingStartDate = true
                state.showDatePicker = true
                return .none

            case .endDateButtonTapped:
                state.isSelectingStartDate = false
                state.showDatePicker = true
                return .none

            case .datePickerDismissed:
                state.showDatePicker = false
                return .none

            case .dateChanged(let date):
                if state.isSelectingStartDate {
                    state.startDate = date
                    state.hasSelectedStartDate = true
                    if date > state.endDate {
                        state.endDate = date
                    }
                    // 시작일 선택 후 자동으로 종료일 선택 모달 열기 (종료일이 있는 경우만)
                    if state.hasEndDate {
                        state.isSelectingStartDate = false
                        state.showDatePicker = true
                    } else {
                        state.showDatePicker = false
                        return .send(.showFrequencyModal)
                    }
                    return .none
                } else {
                    state.endDate = date
                    state.hasSelectedEndDate = true
                    if date < state.startDate {
                        state.startDate = date
                    }
                    state.showDatePicker = false
                    // 종료일 선택 후 자동으로 주기 선택 모달 열기
                    return .send(.showFrequencyModal)
                }

            case .endDateToggled:
                state.hasEndDate.toggle()
                return .none

            case .frequencyTypeChanged(let type):
                state.frequencyType = type
                if type == .daily {
                    state.selectedWeekdays = Set(Weekday.allCases)
                }
                return .none

            case .weekdayToggled(let weekday):
                if state.selectedWeekdays.contains(weekday) {
                    state.selectedWeekdays.remove(weekday)
                } else {
                    state.selectedWeekdays.insert(weekday)
                }
                // 모든 요일이 선택되면 매일로 설정
                if state.selectedWeekdays.count == 7 {
                    state.frequencyType = .daily
                } else {
                    state.frequencyType = .weekly
                }
                return .none

            case .timesPerDayChanged(let times):
                state.timesPerDay = times
                updateDefaultTimes(&state, targetCount: times)
                return .none

            case .timeButtonTapped(let index):
                state.selectedTimeIndex = index
                state.tempTime = state.selectedTimes[safe: index] ?? MedicineTime(hour: 8, minute: 0)
                state.showTimePickerModal = true
                return .none

            case .timeChanged(let index, let newTime):
                if index < state.selectedTimes.count {
                    state.selectedTimes[index] = newTime
                }
                return .none

            case .showFrequencyModal:
                state.showFrequencyModal = true
                return .none

            case .showTimesPerDayModal:
                state.showTimesPerDayModal = true
                return .none

            case .dismissFrequencyModal:
                state.showFrequencyModal = false
                return .none

            case .dismissTimesPerDayModal:
                state.showTimesPerDayModal = false
                return .none

            case .frequencySelected(let frequency, let weekdays):
                state.frequencyType = frequency
                state.selectedWeekdays = weekdays
                state.hasSelectedFrequency = true
                state.showFrequencyModal = false
                // 주기 선택 후 자동으로 횟수 선택 모달 열기
                return .send(.showTimesPerDayModal)

            case .timesSelected(let times):
                state.timesPerDay = times
                state.hasSelectedTimes = true
                updateDefaultTimes(&state, targetCount: times)
                state.showTimesPerDayModal = false
                // 횟수 선택 후 자동으로 첫 번째 시간 선택 모달 열기
                if times > 0 {
                    return .send(.showTimePickerModal(0))
                }
                return .none

            case .showTimePickerModal(let index):
                state.selectedTimeIndex = index
                state.tempTime = state.selectedTimes[safe: index] ?? MedicineTime(hour: 8, minute: 0)
                state.showTimePickerModal = true
                return .none

            case .dismissTimePickerModal:
                state.showTimePickerModal = false
                return .none

            case .tempTimeChanged(let time):
                state.tempTime = time
                return .none

            case .confirmTimeSelection:
                if state.selectedTimeIndex < state.selectedTimes.count {
                    state.selectedTimes[state.selectedTimeIndex] = state.tempTime
                }
                state.showTimePickerModal = false

                // 다음 시간 슬롯이 있으면 자동으로 열기
                let nextIndex = state.selectedTimeIndex + 1
                if nextIndex < state.timesPerDay {
                    return .send(.showTimePickerModal(nextIndex))
                }
                return .none

            case .nextButtonTapped:
                return .none
            }
        }
    }

    // 횟수별 디폴트 시간 설정
    private func updateDefaultTimes(_ state: inout State, targetCount: Int) {
        switch targetCount {
        case 1:
            state.selectedTimes = [MedicineTime(hour: 8, minute: 0)] // 오전 8:00
        case 2:
            state.selectedTimes = [
                MedicineTime(hour: 8, minute: 0),  // 오전 8:00
                MedicineTime(hour: 14, minute: 0)  // 오후 2:00
            ]
        case 3:
            state.selectedTimes = [
                MedicineTime(hour: 8, minute: 0),  // 오전 8:00
                MedicineTime(hour: 14, minute: 0), // 오후 2:00
                MedicineTime(hour: 20, minute: 0)  // 오후 8:00
            ]
        default:
            // 기존 로직 유지
            let currentCount = state.selectedTimes.count
            if currentCount < targetCount {
                let defaultTime = MedicineTime(hour: 8, minute: 0)
                for _ in currentCount..<targetCount {
                    state.selectedTimes.append(defaultTime)
                }
            } else if currentCount > targetCount {
                state.selectedTimes = Array(state.selectedTimes.prefix(targetCount))
            }
        }
    }
}
