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

                        Text("\(viewStore.selectedTimeIndex + 1)번째 시간을 선택해주세요")
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
                        .frame(height: 175)
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
                            .frame(height: 60)

                        HStack(spacing: 8) {
                            Button {
                                viewStore.send(.dismissTimePickerModal)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("닫기")
                                        .font(YKFont.subtitle2)
                                        .foregroundColor(YKColor.Neutral.grey500)
                                    Spacer()
                                }
                                .frame(minHeight: 56)
                            }
                            .background(YKColor.Neutral.grey100)
                            .cornerRadius(16)

                            Button {
                                var hour24 = selectedHour
                                if selectedPeriod == 1 && selectedHour != 12 {
                                    hour24 += 12
                                } else if selectedPeriod == 0 && selectedHour == 12 {
                                    hour24 = 0
                                }
                                let time = MedicineTime(hour: hour24, minute: selectedMinute)
                                viewStore.send(.tempTimeChanged(time))
                                viewStore.send(.confirmTimeSelection)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("선택")
                                        .font(YKFont.subtitle2)
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

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.translatesAutoresizingMaskIntoConstraints = false

        makePickerTransparent(picker)

        DispatchQueue.main.async {
            makePickerTransparent(picker)
        }

        containerView.addSubview(picker)

        let hourLabel = UILabel()
        hourLabel.text = "시"
        hourLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        hourLabel.textColor = UIColor(YKColor.Neutral.grey500)
        hourLabel.translatesAutoresizingMaskIntoConstraints = false

        let minuteLabel = UILabel()
        minuteLabel.text = "분"
        minuteLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        minuteLabel.textColor = UIColor(YKColor.Neutral.grey500)
        minuteLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(hourLabel)
        containerView.addSubview(minuteLabel)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            picker.topAnchor.constraint(equalTo: containerView.topAnchor),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            hourLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            hourLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.frame.width * 0.45 + 16),

            minuteLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            minuteLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.frame.width * 0.80 + 10),
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let picker = uiView.subviews.first(where: { $0 is UIPickerView }) as? UIPickerView else { return }

        makePickerTransparent(picker)

        picker.selectRow(selectedPeriod, inComponent: 0, animated: false)
        picker.selectRow(selectedHour - 1, inComponent: 1, animated: false)
        picker.selectRow(selectedMinute, inComponent: 2, animated: false)

        updateLabelPositions(uiView)
    }

    private func updateLabelPositions(_ containerView: UIView) {
        let hourLabel = containerView.subviews.first { ($0 as? UILabel)?.text == "시" }
        let minuteLabel = containerView.subviews.first { ($0 as? UILabel)?.text == "분" }

        DispatchQueue.main.async {
            let width = containerView.frame.width
            hourLabel?.frame.origin.x = width * 0.45 + 16
            minuteLabel?.frame.origin.x = width * 0.80 + 10
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
            case 0: return 2 // 오전/오후
            case 1: return 12 // 1~12시
            case 2: return 60 // 0~59분
            default: return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            let totalWidth = pickerView.frame.width
            switch component {
            case 0: return totalWidth * 0.40
            case 1: return totalWidth * 0.30
            case 2: return totalWidth * 0.30
            default: return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 44.0
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear

            switch component {
            case 0:
                label.text = row == 0 ? "오전" : "오후"
            case 1:
                label.text = "\(row + 1)"
            case 2:
                label.text = String(format: "%02d", row)
            default:
                label.text = ""
            }

            label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            label.textColor = UIColor(YKColor.Neutral.grey950)
            label.textAlignment = component == 0 ? .center : .left

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            DispatchQueue.main.async {
                self.parent.makePickerTransparent(pickerView)
            }

            switch component {
            case 0:
                parent.selectedPeriod = row
            case 1:
                parent.selectedHour = row + 1
            case 2:
                parent.selectedMinute = row
            default:
                break
            }
        }
    }
}
