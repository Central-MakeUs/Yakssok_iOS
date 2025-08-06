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
                            showAddButton: viewStore.isViewingOwnMedicines,
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
                MedicineSectionView(
                    title: "먹을 약",
                    medicines: viewStore.todayMedicines,
                    isCompleted: false,
                    canToggle: viewStore.isViewingOwnMedicines,
                    animatingMedicineId: viewStore.animatingMedicineId,
                    animationDirection: viewStore.animationDirection,
                    onMedicineToggle: { medicineId in
                        viewStore.send(.medicineToggled(id: medicineId))
                    },
                    onAddMedicine: viewStore.isViewingOwnMedicines ? {
                        viewStore.send(.addMedicineButtonTapped)
                    } : nil
                )
                // 복용 완료 섹션
                MedicineSectionView(
                    title: "복용 완료",
                    medicines: viewStore.completedMedicines,
                    isCompleted: true,
                    canToggle: viewStore.isViewingOwnMedicines,
                    animatingMedicineId: viewStore.animatingMedicineId,
                    animationDirection: viewStore.animationDirection,
                    onMedicineToggle: { medicineId in
                        viewStore.send(.medicineToggled(id: medicineId))
                    },
                    onAddMedicine: nil
                )
            }
        }
    }
}

private struct MedicineSectionView: View {
    let title: String
    let medicines: [Medicine]
    let isCompleted: Bool
    let canToggle: Bool
    let animatingMedicineId: String?
    let animationDirection: MedicineListFeature.AnimationDirection?
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
                animatingMedicineId: animatingMedicineId,
                animationDirection: animationDirection,
                onMedicineToggle: onMedicineToggle
            )
        }
    }
}

private struct MedicineListContainerView: View {
    let medicines: [Medicine]
    let isCompleted: Bool
    let canToggle: Bool
    let animatingMedicineId: String?
    let animationDirection: MedicineListFeature.AnimationDirection?
    let onMedicineToggle: (String) -> Void

    var body: some View {
        VStack(spacing: Layout.medicineItemSpacing) {
            ForEach(medicines) { medicine in
                let isToggleable = canToggle && Int(medicine.id) != nil
                let isAnimating = animatingMedicineId == medicine.id

                AnimatedMedicineItemView(
                    medicine: medicine,
                    isCompleted: isCompleted,
                    canToggle: isToggleable,
                    isAnimating: isAnimating,
                    animationDirection: animationDirection,
                    onToggle: {
                        if isToggleable {
                            onMedicineToggle(medicine.id)
                        }
                    }
                )
            }
        }
    }
}

private struct AnimatedMedicineItemView: View {
    let medicine: Medicine
    let isCompleted: Bool
    let canToggle: Bool
    let isAnimating: Bool
    let animationDirection: MedicineListFeature.AnimationDirection?
    let onToggle: () -> Void

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1

    var body: some View {
        MedicineItemView(
            medicine: medicine,
            isCompleted: isCompleted,
            canToggle: canToggle,
            onToggle: onToggle
        )
        .offset(y: yOffset)
        .opacity(opacity)
        .scaleEffect(scale)
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
    }

    private func startAnimation() {
        guard let direction = animationDirection else { return }

        withAnimation(.easeInOut(duration: 0.15)) {
            scale = 1.05
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
                opacity = 0.3

                switch direction {
                case .toCompleted:
                    // 아래로 이동
                    yOffset = 50
                case .toTodo:
                    // 위로 이동
                    yOffset = -50
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeIn(duration: 0.25)) {
                opacity = 0

                switch direction {
                case .toCompleted:
                    yOffset = 100
                case .toTodo:
                    yOffset = -100
                }
            }
        }
    }

    private func resetAnimation() {
        // 애니메이션 상태 초기화
        withAnimation(.easeOut(duration: 0.2)) {
            yOffset = 0
            opacity = 1
            scale = 1
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let sectionHeaderSpacing: CGFloat = 20
    static let medicineItemSpacing: CGFloat = 8
}
