//
//  MyMedicinesFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation

struct MyMedicinesFeature: Reducer {
    struct State: Equatable {
        var selectedTab: MedicineTab = .all
        var routines: [MedicineRoutine] = []
        var isLoading: Bool = false
        var showDeleteConfirmation: Bool = false
        var selectedRoutineForDeletion: MedicineRoutine?
        var showMoreMenu: Bool = false
        var selectedRoutineForMenu: MedicineRoutine?

        var filteredRoutines: [MedicineRoutine] {
            let routinesWithStatus = routines.map { routine in
                var updatedRoutine = routine
                updatedRoutine.status = determineStatus(for: routine)
                return updatedRoutine
            }

            switch selectedTab {
            case .all:
                return routinesWithStatus.sorted { $0.createdAt > $1.createdAt }
            case .beforeTaking:
                return routinesWithStatus.filter { $0.status == .beforeTaking }.sorted { $0.createdAt > $1.createdAt }
            case .taking:
                return routinesWithStatus.filter { $0.status == .taking }.sorted { $0.createdAt > $1.createdAt }
            case .completed:
                return routinesWithStatus.filter { $0.status == .completed }.sorted { $0.createdAt > $1.createdAt }
            }
        }

        private func determineStatus(for routine: MedicineRoutine) -> MedicineRoutine.MedicineStatus {
            let today = Date()
            let calendar = Calendar.current

            if let startDate = routine.startDate {
                if calendar.compare(startDate, to: today, toGranularity: .day) == .orderedDescending {
                    return .beforeTaking
                }
            }

            if let endDate = routine.endDate {
                if calendar.compare(endDate, to: today, toGranularity: .day) == .orderedAscending {
                    return .completed
                }
            }

            return .taking
        }
    }

    enum MedicineTab: CaseIterable {
        case all, beforeTaking, taking, completed

        var title: String {
            switch self {
            case .all: return "전체"
            case .beforeTaking: return "복약 전"
            case .taking: return "복약 중"
            case .completed: return "복약 종료"
            }
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case backButtonTapped
        case tabSelected(MedicineTab)
        case addMedicineButtonTapped
        case moreButtonTapped(MedicineRoutine)
        case dismissMoreMenu
        case stopMedicineConfirmationRequested(MedicineRoutine)
        case showDeleteConfirmation(MedicineRoutine)
        case dismissDeleteConfirmation
        case confirmStopMedicine
        case routinesLoaded([MedicineRoutine])
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToMyPage
            case navigateToAddMedicine
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let mockRoutines = MyMedicinesFeature.createMockRoutines()
                    await send(.routinesLoaded(mockRoutines))
                }

            case .backButtonTapped:
                return .send(.delegate(.backToMyPage))

            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none

            case .addMedicineButtonTapped:
                return .send(.delegate(.navigateToAddMedicine))

            case .moreButtonTapped(let routine):
                state.selectedRoutineForMenu = routine
                state.showMoreMenu = true
                return .none

            case .dismissMoreMenu:
                state.showMoreMenu = false
                state.selectedRoutineForMenu = nil
                return .none

            case .stopMedicineConfirmationRequested(let routine):
                state.showMoreMenu = false
                state.selectedRoutineForDeletion = routine
                state.showDeleteConfirmation = true
                return .none

            case .showDeleteConfirmation(let routine):
                state.selectedRoutineForDeletion = routine
                state.showDeleteConfirmation = true
                return .none

            case .dismissDeleteConfirmation:
                state.showDeleteConfirmation = false
                state.selectedRoutineForDeletion = nil
                return .none

            case .confirmStopMedicine:
                if let routineToStop = state.selectedRoutineForDeletion {
                    state.routines = state.routines.map { routine in
                        if routine.id == routineToStop.id {
                            var updatedRoutine = routine
                            updatedRoutine.endDate = Date()
                            updatedRoutine.status = .completed
                            return updatedRoutine
                        }
                        return routine
                    }
                }
                state.showDeleteConfirmation = false
                state.selectedRoutineForDeletion = nil
                return .none

            case .routinesLoaded(let routines):
                state.routines = routines
                state.isLoading = false
                return .none

            case .delegate:
                return .none
            }
        }
    }

    static func createMockRoutines() -> [MedicineRoutine] {
        let calendar = Calendar.current
        let today = Date()

        return [
            MedicineRoutine(
                id: "routine1",
                medicineName: "아세트아미노펜",
                schedule: ["오전 8:00", "오전 8:00", "오전 8:00"],
                category: MedicineCategory.defaultCategories[2],
                frequency: MedicineFrequency(
                    type: .weekly([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]),
                    times: [
                        MedicineTime(hour: 8, minute: 0),
                        MedicineTime(hour: 8, minute: 0),
                        MedicineTime(hour: 8, minute: 0)
                    ]
                ),
                startDate: calendar.date(byAdding: .day, value: 1, to: today),
                endDate: calendar.date(byAdding: .day, value: 30, to: today),
                createdAt: calendar.date(byAdding: .hour, value: -2, to: today) ?? today,
                status: .beforeTaking
            ),
            MedicineRoutine(
                id: "routine2",
                medicineName: "아세트아미노펜",
                schedule: ["오전 8:00", "오전 8:00", "오전 8:00"],
                category: MedicineCategory.defaultCategories[2],
                frequency: MedicineFrequency(
                    type: .weekly([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]),
                    times: [
                        MedicineTime(hour: 8, minute: 0),
                        MedicineTime(hour: 8, minute: 0),
                        MedicineTime(hour: 8, minute: 0)
                    ]
                ),
                startDate: calendar.date(byAdding: .day, value: -5, to: today),
                endDate: calendar.date(byAdding: .day, value: 25, to: today),
                createdAt: calendar.date(byAdding: .hour, value: -5, to: today) ?? today,
                status: .taking
            )
        ]
    }
}
