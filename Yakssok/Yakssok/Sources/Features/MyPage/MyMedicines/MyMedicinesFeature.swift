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
        var error: String?

        var filteredRoutines: [MedicineRoutine] {
            switch selectedTab {
            case .all:
                return routines.sorted { $0.createdAt > $1.createdAt }
            case .beforeTaking:
                return routines.filter { $0.status == .beforeTaking }.sorted { $0.createdAt > $1.createdAt }
            case .taking:
                return routines.filter { $0.status == .taking }.sorted { $0.createdAt > $1.createdAt }
            case .completed:
                return routines.filter { $0.status == .completed }.sorted { $0.createdAt > $1.createdAt }
            }
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
        case loadRoutines
        case routinesLoaded([MedicineRoutine])
        case routinesLoadFailed(String)
        case stopMedicine(String)
        case stopMedicineApiSuccess
        case stopMedicineFailed(String)
        case dismissError

        case dataChanged(DataChangeEvent)
        case startDataSubscription
        case stopDataSubscription

        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToMyPage
            case navigateToAddMedicine
        }
    }

    @Dependency(\.medicineClient) var medicineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadRoutines),
                    .send(.startDataSubscription)
                )

            case .startDataSubscription:
                return .run { send in
                    await AppDataManager.shared.subscribe(id: "mymedicines-subscription") { event in
                        await send(.dataChanged(event))
                    }
                }
                .cancellable(id: "mymedicines-subscription")

            case .stopDataSubscription:
                return .run { _ in
                    await AppDataManager.shared.unsubscribe(id: "mymedicines-subscription")
                }
                .cancellable(id: "mymedicines-subscription", cancelInFlight: true)

            case .dataChanged(let event):
                switch event {
                case .medicineAdded, .medicineUpdated, .medicineDeleted, .allDataChanged:
                    return .send(.loadRoutines)
                        .debounce(id: "reload-routines", for: 0.3, scheduler: DispatchQueue.main)
                default:
                    return .none
                }

            case .backButtonTapped:
                return .merge(
                    .send(.stopDataSubscription),
                    .send(.delegate(.backToMyPage))
                )

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

                if routine.status != .taking {
                    state.error = "복약 중인 경우에만 종료할 수 있어요"
                    return .none
                }

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
                guard let routineToStop = state.selectedRoutineForDeletion else { return .none }
                state.showDeleteConfirmation = false
                state.selectedRoutineForDeletion = nil
                return .send(.stopMedicine(routineToStop.id))

            case .loadRoutines:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let medicineData = try await medicineClient.loadMedicineData()
                        let routines = medicineData.routines
                        await send(.routinesLoaded(routines))
                    } catch {
                        await send(.routinesLoadFailed(error.localizedDescription))
                    }
                }

            case .routinesLoaded(let routines):
                state.routines = routines
                state.isLoading = false
                return .none

            case .routinesLoadFailed(let error):
                state.error = error
                state.isLoading = false
                return .none

            case .stopMedicine(let medicationId):
                state.isLoading = true
                return .run { send in
                    do {
                        try await medicineClient.stopMedicine(medicationId)
                        await send(.stopMedicineApiSuccess)
                    } catch {
                        await send(.stopMedicineFailed(error.localizedDescription))
                    }
                }

            case .stopMedicineApiSuccess:
                state.isLoading = false
                return .run { _ in
                    await AppDataManager.shared.notifyDataChanged(.medicineDeleted)
                }

            case .stopMedicineFailed(let error):
                state.error = error
                state.isLoading = false
                return .none

            case .dismissError:
                state.error = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
