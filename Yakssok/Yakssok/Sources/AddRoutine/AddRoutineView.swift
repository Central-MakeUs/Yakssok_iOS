//
//  AddRoutineView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct AddRoutineView: View {
    let store: StoreOf<AddRoutineFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Group {
                    if viewStore.categorySelection != nil {
                        IfLetStore(store.scope(state: \.categorySelection, action: \.categorySelection)) { categoryStore in
                            WithViewStore(categoryStore, observe: { $0 }) { categoryViewStore in
                                AddRoutineContainerView(
                                    currentStep: 1,
                                    isNextButtonEnabled: categoryViewStore.isNextButtonEnabled,
                                    onBackTapped: { viewStore.send(.backButtonTapped) },
                                    onNextTapped: { viewStore.send(.categorySelection(.nextButtonTapped)) },
                                    nextButtonTitle: "다음"
                                ) {
                                    CategorySelectionView(store: categoryStore)
                                }
                            }
                        }
                    } else if viewStore.scheduleSelection != nil {
                        IfLetStore(store.scope(state: \.scheduleSelection, action: \.scheduleSelection)) { scheduleStore in
                            WithViewStore(scheduleStore, observe: { $0 }) { scheduleViewStore in
                                AddRoutineContainerView(
                                    currentStep: 2,
                                    isNextButtonEnabled: scheduleViewStore.isNextButtonEnabled,
                                    onBackTapped: { viewStore.send(.backButtonTapped) },
                                    onNextTapped: { viewStore.send(.scheduleSelection(.nextButtonTapped)) },
                                    nextButtonTitle: "다음"
                                ) {
                                    ScheduleSelectionView(store: scheduleStore)
                                }
                            }
                        }
                    } else if viewStore.alarmSelection != nil {
                        IfLetStore(store.scope(state: \.alarmSelection, action: \.alarmSelection)) { alarmStore in
                            WithViewStore(alarmStore, observe: { $0 }) { alarmViewStore in
                                AddRoutineContainerView(
                                    currentStep: 3,
                                    isNextButtonEnabled: alarmViewStore.isNextButtonEnabled,
                                    onBackTapped: { viewStore.send(.backButtonTapped) },
                                    onNextTapped: { viewStore.send(.alarmSelection(.nextButtonTapped)) },
                                    nextButtonTitle: "완료"
                                ) {
                                    AlarmSelectionView(store: alarmStore)
                                }
                            }
                        }
                    }
                }

                // 스케줄 선택 단계의 커스텀 모달들 - 전체 화면을 덮도록 ZStack 최상위에 배치
                if viewStore.scheduleSelection != nil {
                    IfLetStore(store.scope(state: \.scheduleSelection, action: \.scheduleSelection)) { scheduleStore in
                        WithViewStore(scheduleStore, observe: { $0 }) { scheduleViewStore in
                            if scheduleViewStore.showDatePicker {
                                CustomDatePickerModal(store: scheduleStore)
                            }

                            if scheduleViewStore.showTimePickerModal {
                                CustomTimePickerModal(store: scheduleStore)
                            }

                            if scheduleViewStore.showFrequencyModal {
                                FrequencySelectionModal(store: scheduleStore)
                            }

                            if scheduleViewStore.showTimesPerDayModal {
                                TimesPerDaySelectionModal(store: scheduleStore)
                            }
                        }
                    }
                }

                // 최종 확인 모달
                if viewStore.showFinalCompletionModal {
                    FinalCompletionModal(
                        routineData: viewStore.completedRoutineData,
                        onDismiss: { viewStore.send(.dismissFinalCompletionModal) }
                    )
                }
            }
        }
    }
}
