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
                        .padding(.horizontal, Layout.modalHorizontalPadding)
                        .padding(.bottom, Layout.modalBottomPadding)
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
                    .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                    .cornerRadius(999)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                ModalHeaderView(userName: viewStore.userName)
                ModalMedicineListView(store: store)
                ModalFooterView(store: store)
            }
            .background(
                RoundedRectangle(cornerRadius: Layout.modalCornerRadius)
                    .fill(YKColor.Neutral.grey50)
            )
        }
    }

    private func dismissModal(viewStore: ViewStoreOf<ReminderModalFeature>, action: ReminderModalFeature.Action) {
        withAnimation(.easeIn(duration: 0.25)) {
            isPresented = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            viewStore.send(action)
        }
    }
}

private struct ModalHeaderView: View {
    let userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.headerSpacing) {
            Text("\(userName)님,")
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey900)
            Text("지금 드셔야할 약이에요")
                .font(YKFont.subtitle1)
                .foregroundColor(YKColor.Neutral.grey900)
        }
        .padding(.horizontal, Layout.headerHorizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Layout.headerTopPadding)
        .padding(.bottom, Layout.headerBottomPadding)
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
                    .frame(maxHeight: Layout.maxScrollHeight)
                } else {
                    medicineList(viewStore: viewStore)
                }
            }
            .padding(.horizontal, Layout.medicineListHorizontalPadding)
            .padding(.bottom, Layout.medicineListBottomPadding)
        }
    }

    private func medicineList(viewStore: ViewStoreOf<ReminderModalFeature>) -> some View {
        VStack(spacing: Layout.medicineItemSpacing) {
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
                .frame(width: Layout.medicineDotSize, height: Layout.medicineDotSize)

            HStack(spacing: Layout.infoSpacing) {
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
        .padding(.horizontal, Layout.medicineRowHorizontalPadding)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: Layout.medicineRowCornerRadius)
                .fill(YKColor.Neutral.grey100)
        )
    }

    private var medicineColor: Color {
        switch medicine.color {
        case .purple: return YKColor.Sub.purple
        case .yellow: return YKColor.Sub.yellow
        case .blue: return YKColor.Sub.blue
        case .green: return YKColor.Sub.green
        case .pink: return YKColor.Sub.pink
        }
    }
}



private struct ModalFooterView: View {
    let store: StoreOf<ReminderModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button("지금 먹을게요!") {
                viewStore.send(.takeMedicineNowTapped)
            }
            .font(YKFont.subtitle2)
            .foregroundColor(YKColor.Neutral.grey50)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Layout.footerButtonCornerRadius)
                    .fill(YKColor.Primary.primary400)
            )
            .padding(.horizontal, Layout.footerHorizontalPadding)
            .padding(.bottom, Layout.footerBottomPadding)
        }
    }
}

private enum Layout {
    // 모달 전체
    static let modalCornerRadius: CGFloat = 24
    static let modalHorizontalPadding: CGFloat = 12
    static let modalBottomPadding: CGFloat = 50

    // 헤더
    static let headerSpacing: CGFloat = 5
    static let headerHorizontalPadding: CGFloat = 16
    static let headerTopPadding: CGFloat = 28
    static let headerBottomPadding: CGFloat = 20

    // 복약 리스트
    static let medicineListHorizontalPadding: CGFloat = 16
    static let medicineListBottomPadding: CGFloat = 60
    static let medicineItemSpacing: CGFloat = 12
    static let medicineDotSize: CGFloat = 8
    static let medicineRowVerticalPadding: CGFloat = 16
    static let medicineRowHorizontalPadding: CGFloat = 16
    static let medicineRowCornerRadius: CGFloat = 16
    static let maxScrollHeight: CGFloat = 200
    static let infoSpacing: CGFloat = 8

    // 푸터
    static let footerButtonVerticalPadding: CGFloat = 16
    static let footerButtonCornerRadius: CGFloat = 16
    static let footerHorizontalPadding: CGFloat = 16
    static let footerBottomPadding: CGFloat = 16
}



struct MedicineCategory: Equatable {
    let id: String
    let name: String
    let iconName: String
}

struct DateRange: Equatable {
    let startDate: Date
    let endDate: Date
}

struct MedicineFrequency: Equatable {
    let type: FrequencyType
    let times: [MedicineTime]

    enum FrequencyType: Equatable {
        case daily
        case weekly([Weekday])
    }
}

struct MedicineTime: Equatable {
    let hour: Int
    let minute: Int

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        return formatter.string(from: date)
    }
}

enum Weekday: Int, CaseIterable, Equatable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortName: String {
        switch self {
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        case .sunday: return "일"
        }
    }
}

struct AlarmSound: Equatable {
    let id: String
    let name: String
    let fileName: String
}

struct MedicineInfo: Equatable {
    let name: String
    let dosage: String?
    let color: MedicineColor
}

struct MedicineRegistrationData: Equatable {
    let category: MedicineCategory
    let dateRange: DateRange
    let frequency: MedicineFrequency
    let alarmSound: AlarmSound
    let medicineInfo: MedicineInfo

    func toMedicineRoutine() -> MedicineRoutine {
        let timeStrings = frequency.times.map { $0.timeString }
        return MedicineRoutine(
            id: UUID().uuidString,
            medicineName: medicineInfo.name,
            schedule: timeStrings
        )
    }
}
