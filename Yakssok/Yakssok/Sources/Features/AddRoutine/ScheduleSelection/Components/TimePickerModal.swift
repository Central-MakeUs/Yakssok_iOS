//
//  TimePickerModal.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import UIKit
import ComposableArchitecture
import YakssokDesignSystem

struct TimePickerModal: View {
    let store: StoreOf<ScheduleSelectionFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all) // 모든 Safe Area 무시
                    .onTapGesture {
                        viewStore.send(.dismissTimePickerModal)
                    }

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        // 모달 핸들
                        Rectangle()
                            .fill(YKColor.Neutral.grey300)
                            .frame(width: 37, height: 4)
                            .cornerRadius(2)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        // 제목
                        Text("알림받을 시간을 설정해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey950)
                            .padding(.bottom, 20)

                        // 시간 피커
                        UITimePickerWrapper(
                            hour: viewStore.tempTime.hour,
                            minute: viewStore.tempTime.minute
                        ) { hour, minute in
                            viewStore.send(.tempTimeChanged(MedicineTime(hour: hour, minute: minute)))
                        }
                        .frame(height: 200)
                        .padding(.horizontal, 13.5)

                        Spacer()
                            .frame(height: 50)

                        HStack(spacing: 8) {
                            Button {
                                viewStore.send(.dismissTimePickerModal)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("닫기")
                                        .foregroundColor(YKColor.Neutral.grey400)
                                    Spacer()
                                }
                                .frame(height: 56)
                            }
                            .frame(width: 84)
                            .background(YKColor.Neutral.grey100)
                            .cornerRadius(16)

                            Button {
                                viewStore.send(.confirmTimeSelection)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("선택")
                                        .foregroundColor(YKColor.Neutral.grey50)
                                    Spacer()
                                }
                                .frame(minHeight: 56)
                            }
                            .background(YKColor.Primary.primary400)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                }
            }
        }
    }
}

struct UITimePickerWrapper: UIViewRepresentable {
    let hour: Int
    let minute: Int
    let onTimeChanged: (Int, Int) -> Void

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.setValue(UIColor(YKColor.Neutral.grey950), forKeyPath: "textColor")
        picker.backgroundColor = UIColor.clear

        // 초기 시간 설정
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        if let date = Calendar.current.date(from: components) {
            picker.date = date
        }

        picker.addTarget(context.coordinator, action: #selector(Coordinator.timeChanged), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        if let date = Calendar.current.date(from: components) {
            uiView.date = date
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: UITimePickerWrapper

        init(_ parent: UITimePickerWrapper) {
            self.parent = parent
        }

        @objc func timeChanged(_ sender: UIDatePicker) {
            let components = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
            parent.onTimeChanged(components.hour ?? 0, components.minute ?? 0)
        }
    }
}
