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
                Image(isNaggingType ? "sound-popular" : "sound")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)

                Spacer()

                if isNaggingType {
                    HStack(alignment: .center, spacing: 8) {
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
