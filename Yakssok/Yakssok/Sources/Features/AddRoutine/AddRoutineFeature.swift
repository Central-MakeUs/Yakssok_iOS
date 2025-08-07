//
//  AddRoutineFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture

struct AddRoutineFeature: Reducer {
    struct State: Equatable {
        var currentStep: Int = 1
        var categorySelection: CategorySelectionFeature.State? = .init()
        var scheduleSelection: ScheduleSelectionFeature.State? = nil
        var alarmSelection: AlarmSelectionFeature.State? = nil
        var showFinalCompletionModal: Bool = false
        var completedRoutineData: MedicineRegistrationData? = nil
        var completedCategoryData: CompletedCategoryData? = nil
        var completedScheduleData: CompletedScheduleData? = nil

        // API 관련 상태
        var isSubmitting: Bool = false
        var submitError: String? = nil
    }

    struct CompletedCategoryData: Equatable {
        let medicineName: String
        let category: MedicineCategory
    }

    struct CompletedScheduleData: Equatable {
        let dateRange: DateRange
        let frequency: MedicineFrequency
    }

    @CasePathable
    enum Action: Equatable {
        case backButtonTapped
        case categorySelection(CategorySelectionFeature.Action)
        case scheduleSelection(ScheduleSelectionFeature.Action)
        case alarmSelection(AlarmSelectionFeature.Action)
        case routineCompleted
        case dismissRequested
        case dismissFinalCompletionModal

        // API 관련 액션
        case submitRoutine
        case routineSubmissionSucceeded
        case routineApiSuccess
        case routineSubmissionFailed(String)
        case rollbackRoutineSubmission
    }

    @Dependency(\.medicineClient) var medicineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                if state.currentStep == 2 {
                    state.currentStep = 1
                    state.categorySelection = state.completedCategoryData.map { categoryData in
                        var categoryState = CategorySelectionFeature.State()
                        categoryState.medicineName = categoryData.medicineName
                        categoryState.selectedCategory = categoryData.category
                        return categoryState
                    } ?? .init()
                    return .none

                } else if state.currentStep == 3 {
                    state.currentStep = 2
                    state.scheduleSelection = state.completedScheduleData.map { scheduleData in
                        var scheduleState = ScheduleSelectionFeature.State()
                        scheduleState.startDate = scheduleData.dateRange.startDate
                        scheduleState.endDate = scheduleData.dateRange.endDate
                        scheduleState.hasEndDate = scheduleData.dateRange.startDate != scheduleData.dateRange.endDate

                        switch scheduleData.frequency.type {
                        case .daily:
                            scheduleState.frequencyType = .daily
                            scheduleState.selectedWeekdays = Set(Weekday.allCases)
                        case .weekly(let weekdays):
                            scheduleState.frequencyType = .weekly
                            scheduleState.selectedWeekdays = Set(weekdays)
                        }

                        scheduleState.timesPerDay = scheduleData.frequency.times.count
                        scheduleState.selectedTimes = scheduleData.frequency.times

                        return scheduleState
                    } ?? .init()
                    return .none

                } else {
                    return .send(.dismissRequested)
                }

            case .categorySelection(.nextButtonTapped):
                if let categoryState = state.categorySelection,
                   let selectedCategory = categoryState.selectedCategory {
                    state.completedCategoryData = CompletedCategoryData(
                        medicineName: categoryState.medicineName,
                        category: selectedCategory
                    )
                }

                state.currentStep = 2
                if state.scheduleSelection == nil {
                    state.scheduleSelection = .init()
                }
                return .none

            case .scheduleSelection(.nextButtonTapped):
                if let scheduleState = state.scheduleSelection {
                    let dateRange = DateRange(
                        startDate: scheduleState.startDate,
                        endDate: scheduleState.hasEndDate ? scheduleState.endDate : scheduleState.startDate
                    )

                    let frequency = MedicineFrequency(
                        type: scheduleState.frequencyType == .daily ? .daily : .weekly(Array(scheduleState.selectedWeekdays)),
                        times: scheduleState.selectedTimes
                    )

                    state.completedScheduleData = CompletedScheduleData(
                        dateRange: dateRange,
                        frequency: frequency
                    )
                }

                state.currentStep = 3
                if state.alarmSelection == nil {
                    state.alarmSelection = .init()
                }
                return .none

            case .alarmSelection(.nextButtonTapped):
                if let finalData = createFinalRoutineData(from: state) {
                    state.completedRoutineData = finalData
                    return .send(.submitRoutine)
                } else {
                    print("루틴 데이터 생성 실패")
                    return .none
                }

            case .submitRoutine:
                guard let routineData = state.completedRoutineData else {
                    return .send(.routineSubmissionFailed("루틴 데이터 없음"))
                }

                state.showFinalCompletionModal = true
                state.isSubmitting = false
                state.submitError = nil

                return .run { send in
                    do {
                        try await medicineClient.createMedicineRoutine(routineData)
                        await send(.routineApiSuccess)
                    } catch {
                        await send(.rollbackRoutineSubmission)
                    }
                }

            case .routineApiSuccess:
                return .none

            case .rollbackRoutineSubmission:
                state.showFinalCompletionModal = false
                return .none

            case .dismissFinalCompletionModal:
                state.showFinalCompletionModal = false
                return .send(.routineSubmissionSucceeded)

            case .routineSubmissionSucceeded:
                state.isSubmitting = false
                return .send(.dismissRequested)

            case .routineSubmissionFailed(let error):
                state.isSubmitting = false
                return .none

            case .routineCompleted:
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.categorySelection, action: \.categorySelection) {
            CategorySelectionFeature()
        }
        .ifLet(\.scheduleSelection, action: \.scheduleSelection) {
            ScheduleSelectionFeature()
        }
        .ifLet(\.alarmSelection, action: \.alarmSelection) {
            AlarmSelectionFeature()
        }
    }

    private func createFinalRoutineData(from state: State) -> MedicineRegistrationData? {

        guard let categoryData = state.completedCategoryData,
              let scheduleData = state.completedScheduleData,
              let alarmState = state.alarmSelection else {
            return nil
        }

        let medicineInfo = MedicineInfo(
            name: categoryData.medicineName,
            dosage: nil,
            color: colorFromMedicationCategory(categoryData.category.colorType)
        )


        let data = MedicineRegistrationData(
            category: categoryData.category,
            dateRange: scheduleData.dateRange,
            frequency: scheduleData.frequency,
            alarmSound: alarmState.selectedAlarmType.toAlarmSound,
            medicineInfo: medicineInfo
        )

        return data
    }
}
