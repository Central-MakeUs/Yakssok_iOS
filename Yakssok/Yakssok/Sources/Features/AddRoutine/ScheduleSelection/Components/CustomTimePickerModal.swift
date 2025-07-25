//
//  CustomTimePickerModal.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct CustomTimePickerModal: View {
    let store: StoreOf<ScheduleSelectionFeature>
    @State private var selectedPeriod: Int = 0 // 0: 오전, 1: 오후
    @State private var selectedHour: Int = 8
    @State private var selectedMinute: Int = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.dismissTimePickerModal)
                    }

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)

                        // 제목 수정
                        Text("알림받을 시간을 설정해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                            .padding(.bottom, 20)
                            .padding(.top, 28)

                        CustomTimePicker(
                            selectedPeriod: $selectedPeriod,
                            selectedHour: $selectedHour,
                            selectedMinute: $selectedMinute
                        )
                        .frame(height: 200)
                        .background(Color.clear)
                        .overlay(
                            VStack(spacing: 40) {
                                Rectangle()
                                    .fill(YKColor.Primary.primary300)
                                    .frame(height: 1)
                                Rectangle()
                                    .fill(YKColor.Primary.primary300)
                                    .frame(height: 1)
                            }
                        )
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 50)

                        HStack(spacing: 8) {
                            Button("닫기") {
                                    viewStore.send(.dismissTimePickerModal)
                                }
                                .font(YKFont.subtitle2)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(YKColor.Neutral.grey100)
                                .foregroundColor(YKColor.Neutral.grey500)
                                .cornerRadius(16)

                            Button("선택") {
                                var hour24 = selectedHour
                                if selectedPeriod == 1 && selectedHour != 12 { // 오후이고 12시가 아닌 경우
                                    hour24 += 12
                                } else if selectedPeriod == 0 && selectedHour == 12 { // 오전 12시인 경우
                                    hour24 = 0
                                }
                                let time = MedicineTime(hour: hour24, minute: selectedMinute)
                                viewStore.send(.tempTimeChanged(time))
                                viewStore.send(.confirmTimeSelection)
                            }
                            .font(YKFont.subtitle2)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(YKColor.Primary.primary400)
                                .foregroundColor(YKColor.Neutral.grey50)
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
            .onAppear {
                let hour = viewStore.tempTime.hour
                selectedPeriod = hour < 12 ? 0 : 1
                if hour == 0 {
                    selectedHour = 12
                } else if hour > 12 {
                    selectedHour = hour - 12
                } else {
                    selectedHour = hour
                }
                selectedMinute = viewStore.tempTime.minute
            }
        }
    }
}

struct CustomTimePicker: UIViewRepresentable {
    @Binding var selectedPeriod: Int
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator

        // 초기 투명화
        makePickerTransparent(picker)

        // 뷰가 완전히 로드된 후 한 번 더 투명화 적용
        DispatchQueue.main.async {
            self.makePickerTransparent(picker)
        }

        // 0.1초 후에도 한 번 더 적용 (완전한 로드 보장)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.makePickerTransparent(picker)
        }

        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.selectRow(selectedPeriod, inComponent: 0, animated: false)
        uiView.selectRow(selectedHour - 1, inComponent: 1, animated: false)
        uiView.selectRow(selectedMinute, inComponent: 2, animated: false)

        // 업데이트 후에도 투명화 적용
        DispatchQueue.main.async {
            self.makePickerTransparent(uiView)
        }
    }

    private func makePickerTransparent(_ picker: UIPickerView) {
        picker.backgroundColor = UIColor.clear

        func clearBackgroundOnly(view: UIView) {
            view.backgroundColor = UIColor.clear

            if !(view is UILabel) {
                for subview in view.subviews {
                    clearBackgroundOnly(view: subview)
                }
            }
        }

        clearBackgroundOnly(view: picker)

        // 선택 영역의 회색 배경만 제거 (텍스트는 건드리지 않음)
        picker.subviews.forEach { subview in
            if !(subview is UILabel) {
                subview.backgroundColor = UIColor.clear
                if subview.frame.height < 50 && subview.subviews.isEmpty {
                    subview.isHidden = true
                }

                subview.subviews.forEach { subSubview in
                    if !(subSubview is UILabel) {
                        subSubview.backgroundColor = UIColor.clear
                        if subSubview.frame.height < 50 && subSubview.subviews.isEmpty {
                            subSubview.isHidden = true
                        }
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let parent: CustomTimePicker

        init(_ parent: CustomTimePicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return 2 // 오전, 오후
            case 1: return 12 // 1-12시
            case 2: return 60 // 0-59분
            default: return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear

            switch component {
            case 0: // 오전/오후
                label.text = row == 0 ? "오전" : "오후"
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)

            case 1: // 시
                let hourText = "\(row + 1)"
                let unitText = "시"

                // 현재 피커에서 선택된 시와 비교
                let isSelected = row == pickerView.selectedRow(inComponent: 1)

                let attributedString = NSMutableAttributedString()
                attributedString.append(NSAttributedString(
                    string: hourText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                        .foregroundColor: UIColor(YKColor.Neutral.grey950)
                    ]
                ))

                // 선택된 것만 "시" 표시
                if isSelected {
                    attributedString.append(NSAttributedString(
                        string: "   " + unitText,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                            .foregroundColor: UIColor(YKColor.Neutral.grey500)
                        ]
                    ))
                }

                label.attributedText = attributedString

            case 2: // 분
                let minuteText = String(format: "%02d", row)
                let unitText = "분"

                // 현재 피커에서 선택된 분과 비교
                let isSelected = row == pickerView.selectedRow(inComponent: 2)

                let attributedString = NSMutableAttributedString()
                attributedString.append(NSAttributedString(
                    string: minuteText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                        .foregroundColor: UIColor(YKColor.Neutral.grey950)
                    ]
                ))

                // 선택된 것만 "분" 표시
                if isSelected {
                    attributedString.append(NSAttributedString(
                        string: "   " + unitText,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                            .foregroundColor: UIColor(YKColor.Neutral.grey500)
                        ]
                    ))
                }

                label.attributedText = attributedString

            default:
                break
            }

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                parent.selectedPeriod = row
            case 1:
                parent.selectedHour = row + 1
                pickerView.reloadComponent(1) // 시 컴포넌트 리로드 추가 (선택된 것만 "시" 표시하기 위해)
            case 2:
                parent.selectedMinute = row
                pickerView.reloadComponent(2) // 분 컴포넌트 리로드 추가 (선택된 것만 "분" 표시하기 위해)
            default:
                break
            }
        }
    }
}
