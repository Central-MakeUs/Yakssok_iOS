//
//  MyMedicinesView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MyMedicinesView: View {
    let store: StoreOf<MyMedicinesFeature>

    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    YKColor.Neutral.grey100
                        .ignoresSafeArea(.all)

                    YKNavigationBar(
                        title: "내 복약",
                        hasBackButton: true,
                        onBackTapped: {
                            viewStore.send(.backButtonTapped)
                        }
                    ) {

                        VStack(spacing: 0) {
                            MedicineTabBar(
                                selectedTab: viewStore.selectedTab,
                                onTabSelected: { tab in
                                    viewStore.send(.tabSelected(tab))
                                }
                            )

                            ScrollView {
                                VStack(spacing: Layout.contentSpacing) {
                                    // 복약 추가하기 버튼
                                    HStack {
                                        Spacer()
                                        AddMedicineButton {
                                            viewStore.send(.addMedicineButtonTapped)
                                        }
                                    }
                                    .padding(.horizontal, Layout.horizontalPadding)

                                    // 복약 리스트
                                    LazyVStack(spacing: Layout.medicineItemSpacing) {
                                        ForEach(viewStore.filteredRoutines) { routine in
                                            MedicineRoutineCard(
                                                routine: routine,
                                                onMoreTapped: {
                                                    viewStore.send(.moreButtonTapped(routine))
                                                }
                                            )
                                            .padding(.horizontal, Layout.horizontalPadding)
                                        }
                                    }
                                }
                                .padding(.bottom, Layout.bottomSpacing)
                            }
                        }
                    }

                    // 더보기 메뉴 모달
                    if viewStore.showMoreMenu {
                        MoreMenuModal(
                            routine: viewStore.selectedRoutineForMenu,
                            onDismiss: { viewStore.send(.dismissMoreMenu) },
                            onStopMedicine: { routine in
                                viewStore.send(.stopMedicineConfirmationRequested(routine))
                            }
                        )
                    }

                    // 복약 종료 확인 모달
                    if viewStore.showDeleteConfirmation {
                        StopMedicineConfirmationModal(
                            routine: viewStore.selectedRoutineForDeletion,
                            onDismiss: { viewStore.send(.dismissDeleteConfirmation) },
                            onConfirm: { viewStore.send(.confirmStopMedicine) }
                        )
                    }

                    // 에러 메시지 토스트
                    WithViewStore(store, observe: \.error) { errorViewStore in
                        if let error = errorViewStore.state {
                            MessageOverlay(
                                message: error,
                                onDismiss: { store.send(.dismissError) }
                            )
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .navigationBarHidden(true)
                .onAppear {
                    store.send(.onAppear)
                }
            }
        }
    }
}


// 탭 바
private struct MedicineTabBar: View {
    let selectedTab: MyMedicinesFeature.MedicineTab
    let onTabSelected: (MyMedicinesFeature.MedicineTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MyMedicinesFeature.MedicineTab.allCases, id: \.self) { tab in
                Button(action: {
                    onTabSelected(tab)
                }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(YKFont.body1)
                            .foregroundColor(selectedTab == tab ? YKColor.Neutral.grey900 : YKColor.Neutral.grey400)

                        Rectangle()
                            .fill(selectedTab == tab ? YKColor.Neutral.grey900 : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .background(YKColor.Neutral.grey100)
    }
}

private struct AddMedicineButton: View {
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 4) {
                Text("복약추가하기")
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey600)

                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(YKColor.Neutral.grey400)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(YKColor.Neutral.grey200, lineWidth: 1)
            )
        }
        .padding(.top, Layout.addButtonTopPadding)
    }
}

private struct MedicineRoutineCard: View {
    let routine: MedicineRoutine
    let onMoreTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(routine.category.colorType.textColor)
                            .frame(width: 6, height: 6)

                        Text(routine.category.name)
                            .font(YKFont.caption1)
                            .foregroundColor(routine.category.colorType.textColor)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .background(routine.category.colorType.backgroundColor)
                    .cornerRadius(9999)

                    // 상태 태그 추가
                    HStack(spacing: 5) {
                        Text(routine.status.displayText)
                            .font(YKFont.caption1)
                            .foregroundColor(routine.status.textColor)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .background(routine.status.backgroundColor)
                    .cornerRadius(9999)

                    Spacer()

                    // 더보기 버튼
                    Button(action: onMoreTapped) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(YKColor.Neutral.grey400)
                            .rotationEffect(.degrees(90))
                    }
                }
                .padding(.bottom, 16)

                // 약 이름
                Text(routine.medicineName)
                    .font(YKFont.subtitle1)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .padding(.bottom, 8)

                // 복용 요일
                HStack(spacing: 4) {
                    ForEach(Array(getWeekdayList(for: routine.frequency).enumerated()), id: \.offset) { index, weekday in
                        VStack(alignment: .center, spacing: 8) {
                            Text(weekday)
                                .font(YKFont.body2)
                                .foregroundColor(YKColor.Neutral.grey600)
                        }
                        .padding(2)
                        .frame(width: 25, alignment: .center)
                        .background(YKColor.Neutral.grey100)
                        .cornerRadius(4)

                        if index < getWeekdayList(for: routine.frequency).count - 1 {
                            Text("·")
                                .font(YKFont.body2)
                                .foregroundColor(YKColor.Neutral.grey300)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image("alarm")
                        .frame(width: 20, height: 20)
                    Text("하루에 \(routine.frequency.times.count)번")
                        .font(YKFont.body1)
                        .foregroundColor(YKColor.Neutral.grey600)
                }

                Text(routine.frequency.times.map { $0.timeString }.joined(separator: " / "))
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all, 16)
            .background(YKColor.Neutral.grey50)
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(YKColor.Neutral.grey100, lineWidth: 1)

            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(YKColor.Neutral.grey50)
                .stroke(YKColor.Neutral.grey200, lineWidth: 1)
        )
    }

    private func getWeekdayList(for frequency: MedicineFrequency) -> [String] {
        switch frequency.type {
        case .daily:
            return ["월", "화", "수", "목", "금", "토", "일"]
        case .weekly(let weekdays):
            if weekdays.count == 7 {
                return ["월", "화", "수", "목", "금", "토", "일"]
            } else {
                let sortedWeekdays = weekdays.sorted { $0.rawValue < $1.rawValue }
                return sortedWeekdays.map { $0.shortName }
            }
        }
    }
}

private struct MoreMenuModal: View {
    let routine: MedicineRoutine?
    let onDismiss: () -> Void
    let onStopMedicine: (MedicineRoutine) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 37.44, height: 4)
                        .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                        .cornerRadius(999)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    if let routine = routine {
                        Button(action: { onStopMedicine(routine) }) {
                            HStack {
                                Text("종료하기")
                                    .font(YKFont.subtitle1)
                                    .foregroundColor(YKColor.Neutral.grey900)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(YKColor.Neutral.grey400)
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .background(YKColor.Neutral.grey50)
                .cornerRadius(24)
                .padding(.horizontal, 13.5)
                .padding(.bottom, 50)
            }
        }
    }
}

private struct StopMedicineConfirmationModal: View {
    let routine: MedicineRoutine?
    let onDismiss: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 37.44, height: 4)
                        .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                        .cornerRadius(999)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    VStack(spacing: 16) {
                        Text("이 복약 루틴을 종료하시겠습니까?")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("오늘부터 이 루틴을 진행하지 않게 됩니다.")
                            .font(YKFont.body1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)

                    HStack(spacing: 8) {
                        Button {
                            onDismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("취소")
                                    .foregroundColor(YKColor.Neutral.grey500)
                                Spacer()
                            }
                            .frame(height: 56)
                        }
                        .background(YKColor.Neutral.grey100)
                        .cornerRadius(16)

                        Button {
                            onConfirm()
                        } label: {
                            HStack {
                                Spacer()
                                Text("종료")
                                    .foregroundColor(YKColor.Neutral.grey500)
                                Spacer()
                            }
                            .frame(height: 56)
                        }
                        .background(YKColor.Neutral.grey100)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(YKColor.Neutral.grey50)
                .cornerRadius(24)
                .padding(.horizontal, 13.5)
                .padding(.bottom, 50)
            }
        }
    }
}

private struct MessageOverlay: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 16) {
                Text(message)
                    .font(YKFont.subtitle2)
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(YKColor.Neutral.grey900)
            .cornerRadius(12)
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss()
            }
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let contentSpacing: CGFloat = 16
    static let medicineItemSpacing: CGFloat = 12
    static let bottomSpacing: CGFloat = 32
    static let addButtonTopPadding: CGFloat = 8
}
