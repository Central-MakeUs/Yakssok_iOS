//
//  MedicineListView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MedicineListView: View {
    let store: StoreOf<MedicineListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                switch viewStore.medicineState {
                case .noRoutines:
                    VStack(spacing: Layout.sectionSpacing) {
                        MedicineSectionHeaderView(
                            title: "먹을 약",
                            showAddButton: viewStore.isViewingOwnMedicines,
                            onAddTapped: {
                                viewStore.send(.addMedicineButtonTapped)
                            }
                        )
                        NoRoutinesView {
                            viewStore.send(.addMedicineButtonTapped)
                        }
                    }
                case .noMedicineToday:
                    VStack(spacing: Layout.sectionSpacing) {
                        MedicineSectionHeaderView(
                            title: "먹을 약",
                            showAddButton: viewStore.isViewingOwnMedicines, // 본인 것만 볼 때만 추가 버튼 표시
                            onAddTapped: {
                                viewStore.send(.addMedicineButtonTapped)
                            }
                        )
                        NoMedicineTodayView {
                            viewStore.send(.addMedicineButtonTapped)
                        }
                    }
                case .hasMedicines:
                    HasMedicinesView(store: store)
                }
            }
            .padding(.horizontal, Layout.horizontalPadding)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private struct MedicineSectionHeaderView: View {
    let title: String
    let showAddButton: Bool
    let onAddTapped: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey400)

            Spacer()

            if showAddButton {
                Button(action: {
                    onAddTapped?()
                }) {
                    Image("add-pill")
                }
            }
        }
    }
}

private struct HasMedicinesView: View {
    let store: StoreOf<MedicineListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.sectionSpacing) {
                // 먹을 약 섹션
                if !viewStore.todayMedicines.isEmpty {
                    MedicineSectionView(
                        title: "먹을 약",
                        medicines: viewStore.todayMedicines,
                        isCompleted: false,
                        canToggle: viewStore.isViewingOwnMedicines,
                        onMedicineToggle: { medicineId in
                            viewStore.send(.medicineToggled(id: medicineId))
                        },
                        onAddMedicine: viewStore.isViewingOwnMedicines ? {
                            viewStore.send(.addMedicineButtonTapped)
                        } : nil
                    )
                }
                // 복용 완료 섹션
                if !viewStore.completedMedicines.isEmpty {
                    MedicineSectionView(
                        title: "복용 완료",
                        medicines: viewStore.completedMedicines,
                        isCompleted: true,
                        canToggle: viewStore.isViewingOwnMedicines,
                        onMedicineToggle: { medicineId in
                            viewStore.send(.medicineToggled(id: medicineId))
                        },
                        onAddMedicine: nil
                    )
                }
            }
        }
    }
}

private struct MedicineSectionView: View {
    let title: String
    let medicines: [Medicine]
    let isCompleted: Bool
    let canToggle: Bool
    let onMedicineToggle: (String) -> Void
    let onAddMedicine: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionHeaderSpacing) {
            MedicineSectionHeaderView(
                title: title,
                showAddButton: !isCompleted && onAddMedicine != nil,
                onAddTapped: onAddMedicine
            )
            MedicineListContainerView(
                medicines: medicines,
                isCompleted: isCompleted,
                canToggle: canToggle,
                onMedicineToggle: onMedicineToggle
            )
        }
    }
}

private struct MedicineListContainerView: View {
    let medicines: [Medicine]
    let isCompleted: Bool
    let canToggle: Bool
    let onMedicineToggle: (String) -> Void

    var body: some View {
        VStack(spacing: Layout.medicineItemSpacing) {
            ForEach(medicines) { medicine in
                MedicineItemView(
                    medicine: medicine,
                    isCompleted: isCompleted,
                    canToggle: canToggle,
                    onToggle: {
                        onMedicineToggle(medicine.id)
                    }
                )
            }
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let sectionHeaderSpacing: CGFloat = 20
    static let medicineItemSpacing: CGFloat = 8
}
