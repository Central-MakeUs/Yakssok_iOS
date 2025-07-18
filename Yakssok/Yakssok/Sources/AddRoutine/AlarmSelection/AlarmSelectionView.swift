//
//  AlarmSelectionView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct AlarmSelectionView: View {
    let store: StoreOf<AlarmSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                Text("받고 싶은 알람음을 선택해주세요")
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    ForEach(AlarmSelectionFeature.State.AlarmType.allCases, id: \.self) { alarmType in
                        AlarmOptionButton(
                            alarmType: alarmType,
                            isSelected: viewStore.selectedAlarmType == alarmType,
                            isPlaying: viewStore.currentlyPlayingAlarm == alarmType,
                            onTap: { viewStore.send(.alarmTypeSelected(alarmType)) }
                        )
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }
}

struct AlarmOptionButton: View {
    let alarmType: AlarmSelectionFeature.State.AlarmType
    let isSelected: Bool
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                Image(isSelected ? "sound-popular" : "sound")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)

                Spacer()

                if isNaggingType {
                    HStack(alignment: .center) {
                        Text("인기")
                            .font(YKFont.body2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.91, green: 0.47, blue: 0.06), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.98, green: 0.33, blue: 0.24), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 1.18, y: 0.86),
                            endPoint: UnitPoint(x: -0.08, y: 0.02)
                        )
                    )
                    .cornerRadius(8)
                }
            }
            .overlay(
                Text(alarmType.displayName)
                    .font(YKFont.body1)
                    .foregroundColor(textColor)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(borderGradient, lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }

    private var backgroundColor: Color {
        return YKColor.Neutral.grey50
    }

    private var borderGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.96, green: 0.23, blue: 0.09), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.98, green: 0.33, blue: 0.24), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
        } else {
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Color.clear, location: 0.00),
                    Gradient.Stop(color: Color.clear, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
        }
    }

    private var textColor: Color {
        if isSelected {
            return YKColor.Primary.primary400
        } else {
            return YKColor.Neutral.grey950
        }
    }

    private var iconColor: Color {
        if isSelected {
            return YKColor.Primary.primary400
        } else {
            return YKColor.Neutral.grey400
        }
    }

    private var isNaggingType: Bool {
        switch alarmType {
        case AlarmSelectionFeature.State.AlarmType.nagging:
            return true
        default:
            return false
        }
    }
}

struct FinalCompletionModal: View {
    let routineData: MedicineRegistrationData?
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // 핸들바
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 37.44, height: 4)
                        .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                        .cornerRadius(999)
                        .padding(.top, 12)

                    HStack(spacing: 4) {
                        Text("복약알림이 등록되었어요!")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                        Image("hands-up")
                            .frame(width: 24, height: 24)
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 20)
                    .padding(.top, 28)

                    // 루틴 정보 카드
                    if let registrationData = routineData {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(registrationData.category.colorType.textColor)
                                            .frame(width: 6, height: 6)

                                        Text(registrationData.category.name)
                                            .font(YKFont.caption1)
                                            .foregroundColor(registrationData.category.colorType.textColor)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                    .background(registrationData.category.colorType.backgroundColor)
                                    .cornerRadius(9999)

                                    Spacer()
                                }
                                .padding(.bottom, 16)

                                // 약 이름
                                Text(registrationData.medicineInfo.name)
                                    .font(YKFont.subtitle1)
                                    .foregroundColor(YKColor.Neutral.grey950)
                                    .padding(.bottom, 8)

                                // 복용 요일 (점 구분자 포함)
                                HStack(spacing: 4) {
                                    ForEach(Array(getWeekdayList(for: registrationData.frequency).enumerated()), id: \.offset) { index, weekday in
                                        VStack(alignment: .center, spacing: 8) {
                                            Text(weekday)
                                                .font(YKFont.body2)
                                                .foregroundColor(YKColor.Neutral.grey600)
                                        }
                                        .padding(2)
                                        .frame(width: 25, alignment: .center)
                                        .background(YKColor.Neutral.grey100)
                                        .cornerRadius(4)

                                        // 마지막이 아니면 점 구분자 추가
                                        if index < getWeekdayList(for: registrationData.frequency).count - 1 {
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
                                    Text("하루에 \(registrationData.frequency.times.count)번")
                                        .font(YKFont.body1)
                                        .foregroundColor(YKColor.Neutral.grey600)
                                }

                                // 복용 시간
                                Text(registrationData.frequency.times.map { $0.timeString }.joined(separator: " / "))
                                    .font(YKFont.body2)
                                    .foregroundColor(YKColor.Neutral.grey600)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.all, 16)
                            .background(YKColor.Neutral.grey100)
                            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(YKColor.Neutral.grey50)
                                .stroke(YKColor.Neutral.grey200, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                        .frame(height: 60)

                    // 완료 버튼
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("완료")
                            .font(YKFont.subtitle2)
                            .foregroundColor(YKColor.Neutral.grey50)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Primary.primary400)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(YKColor.Neutral.grey50)
                .cornerRadius(24)
                .padding(.horizontal, 13.5)
            }
        }
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
