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
        var scheduleSelection: ScheduleSelectionFeature.State?
        var alarmSelection: AlarmSelectionFeature.State?
    }

    @CasePathable
    enum Action: Equatable {
        case backButtonTapped
        case categorySelection(CategorySelectionFeature.Action)
        case scheduleSelection(ScheduleSelectionFeature.Action)
        case alarmSelection(AlarmSelectionFeature.Action)
        case routineCompleted
        case dismissRequested
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                if state.currentStep == 2 {
                    state.currentStep = 1
                    state.scheduleSelection = nil
                    state.categorySelection = .init()
                    return .none
                } else if state.currentStep == 3 {
                    state.currentStep = 2
                    state.alarmSelection = nil
                    state.scheduleSelection = .init()
                    return .none
                } else {
                    return .send(.dismissRequested)
                }
            case .categorySelection(.nextButtonTapped):
                state.currentStep = 2
                state.categorySelection = nil
                state.scheduleSelection = .init()
                return .none
            case .scheduleSelection(.nextButtonTapped):
                state.currentStep = 3
                state.scheduleSelection = nil
                state.alarmSelection = .init()
                return .none
            case .alarmSelection(.nextButtonTapped):
                return .send(.routineCompleted)
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
}
