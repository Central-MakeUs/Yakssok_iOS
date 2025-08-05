//
//  ReminderModalView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct ReminderModalView: View {
    let store: StoreOf<ReminderModalFeature>
    @State private var isPresented = false

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .opacity(isPresented ? 1 : 0)
                    .onTapGesture {
                        viewStore.send(.closeButtonTapped)
                    }
                VStack(spacing: 0) {
                    Spacer()
                    modalContent
                        .padding(.horizontal, ReminderModalConstants.Layout.modalHorizontalPadding)
                        .padding(.bottom, ReminderModalConstants.Layout.modalBottomPadding)
                        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isPresented = true
                }
            }
        }
    }

    private var modalContent: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 37.44, height: 4)
                    .background(YKColor.Neutral.grey300)
                    .cornerRadius(999)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ModalHeaderView(userName: viewStore.userName)
                ModalMedicineListView(store: store)
                ModalFooterView(store: store)
            }
            .background(
                RoundedRectangle(cornerRadius: ReminderModalConstants.Layout.modalCornerRadius)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }
}

private struct ModalHeaderView: View {
    let userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: ReminderModalConstants.Layout.headerSpacing) {
            Text(ReminderModalConstants.Text.greeting(userName))
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey900)
            Text(ReminderModalConstants.Text.reminderMessage)
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey900)
        }
        .padding(.horizontal, ReminderModalConstants.Layout.headerHorizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ReminderModalConstants.Layout.headerTopPadding)
        .padding(.bottom, ReminderModalConstants.Layout.headerBottomPadding)
    }
}

private struct ModalMedicineListView: View {
    let store: StoreOf<ReminderModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.shouldScroll {
                    ScrollView {
                        medicineList(viewStore: viewStore)
                    }
                    .frame(maxHeight: ReminderModalConstants.Layout.maxScrollHeight)
                } else {
                    medicineList(viewStore: viewStore)
                }
            }
            .padding(.horizontal, ReminderModalConstants.Layout.medicineListHorizontalPadding)
            .padding(.bottom, ReminderModalConstants.Layout.medicineListBottomPadding)
        }
    }

    private func medicineList(viewStore: ViewStoreOf<ReminderModalFeature>) -> some View {
        VStack(spacing: ReminderModalConstants.Layout.medicineItemSpacing) {
            ForEach(viewStore.missedMedicines) { medicine in
                MissedMedicineItemView(medicine: medicine)
            }
        }
    }
}

private struct MissedMedicineItemView: View {
    let medicine: Medicine

    var body: some View {
        HStack {
            Circle()
                .fill(medicineColor)
                .frame(
                    width: ReminderModalConstants.Layout.medicineDotSize,
                    height: ReminderModalConstants.Layout.medicineDotSize
                )

            HStack(spacing: ReminderModalConstants.Layout.infoSpacing) {
                Text(medicine.name)
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey950)
                Rectangle()
                    .fill(YKColor.Neutral.grey300)
                    .frame(width: 1, height: 12)
                Text(medicine.time)
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey400)
            }
            Spacer()
        }
        .padding(.horizontal, ReminderModalConstants.Layout.medicineRowHorizontalPadding)
        .frame(height: ReminderModalConstants.Layout.medicineRowHeight)
        .background(
            RoundedRectangle(cornerRadius: ReminderModalConstants.Layout.medicineRowCornerRadius)
                .fill(YKColor.Neutral.grey100)
        )
    }

    private var medicineColor: Color {
        switch medicine.color {
        case .purple: return YKColor.Sub.purple
        case .blue: return YKColor.Sub.blue
        case .green: return YKColor.Sub.green
        case .pink: return YKColor.Sub.pink
        case .yellow: return Color(red: 0.91, green: 0.62, blue: 0.09)
        case .orange: return Color(red: 0.86, green: 0.49, blue: 0.14)
        case .red: return Color(red: 0.86, green: 0.14, blue: 0.15)
        }
    }
}

private struct ModalFooterView: View {
    let store: StoreOf<ReminderModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button(ReminderModalConstants.Text.actionButtonTitle) {
                viewStore.send(.takeMedicineNowTapped)
            }
            .font(YKFont.subtitle2)
            .foregroundColor(YKColor.Neutral.grey50)
            .frame(maxWidth: .infinity)
            .frame(height: ReminderModalConstants.Layout.footerButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: ReminderModalConstants.Layout.footerButtonCornerRadius)
                    .fill(YKColor.Primary.primary400)
            )
            .padding(.horizontal, ReminderModalConstants.Layout.footerHorizontalPadding)
            .padding(.bottom, ReminderModalConstants.Layout.footerBottomPadding)
        }
    }
}
