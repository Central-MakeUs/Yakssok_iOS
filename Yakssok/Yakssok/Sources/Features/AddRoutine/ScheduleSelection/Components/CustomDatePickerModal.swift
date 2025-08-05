//
//  CustomDatePickerModal.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import SwiftUI
import UIKit
import ComposableArchitecture
import YakssokDesignSystem

struct CustomDatePickerModal: View {
    let store: StoreOf<ScheduleSelectionFeature>
    @State private var selectedYear: Int = 2025
    @State private var selectedMonth: Int = 6
    @State private var selectedDay: Int = 11

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.datePickerDismissed)
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

                        Text(viewStore.isSelectingStartDate ? "복용 시작 날짜를 설정해주세요" : "복용 종료 날짜를 설정해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                            .padding(.bottom, 20)
                            .padding(.top, 28)

                        CustomDatePicker(
                            selectedYear: $selectedYear,
                            selectedMonth: $selectedMonth,
                            selectedDay: $selectedDay
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

                        // 종료일 없음 체크박스 (종료일 선택시만)
                        if !viewStore.isSelectingStartDate {
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("종료일 없음")
                                        .font(YKFont.body1)
                                        .foregroundColor(YKColor.Neutral.grey950)

                                    Button(action: {
                                        viewStore.send(.endDateToggled)
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .fill(viewStore.hasEndDate ? YKColor.Neutral.grey100 : YKColor.Neutral.grey800)
                                                .frame(width: 24, height: 24)
                                                .cornerRadius(6.57)
                                            Image(viewStore.hasEndDate ? "check-no" : "check-yes")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 20)
                            }
                        }

                        Spacer()
                            .frame(height: 60)

                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.datePickerDismissed)
                            }
                            .font(YKFont.subtitle2)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey500)
                            .cornerRadius(16)

                            Button("선택") {
                                let components = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
                                if let date = Calendar.current.date(from: components) {
                                    viewStore.send(.dateChanged(date))
                                }
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
                let targetDate = viewStore.isSelectingStartDate ? viewStore.startDate : viewStore.endDate
                let components = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
                selectedYear = components.year ?? 2025
                selectedMonth = components.month ?? 6
                selectedDay = components.day ?? 11
            }
        }
    }

    private func daysInMonth(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: dateComponents)!
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
}

struct CustomDatePicker: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.translatesAutoresizingMaskIntoConstraints = false

        makePickerTransparent(picker)

        containerView.addSubview(picker)

        let monthLabel = UILabel()
        monthLabel.text = "월"
        monthLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        monthLabel.textColor = UIColor(YKColor.Neutral.grey500)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false

        let dayLabel = UILabel()
        dayLabel.text = "일"
        dayLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        dayLabel.textColor = UIColor(YKColor.Neutral.grey500)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(monthLabel)
        containerView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            picker.topAnchor.constraint(equalTo: containerView.topAnchor),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            monthLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.frame.width * 0.45 + 16),

            dayLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.frame.width * 0.80 + 4),
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let picker = uiView.subviews.first(where: { $0 is UIPickerView }) as? UIPickerView else { return }

        makePickerTransparent(picker)

        let yearIndex = selectedYear - 2025
        picker.selectRow(yearIndex, inComponent: 0, animated: false)
        picker.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        picker.selectRow(selectedDay - 1, inComponent: 2, animated: false)

        updateLabelPositions(uiView)
    }

    private func updateLabelPositions(_ containerView: UIView) {
        let monthLabel = containerView.subviews.first { ($0 as? UILabel)?.text == "월" }
        let dayLabel = containerView.subviews.first { ($0 as? UILabel)?.text == "일" }

        DispatchQueue.main.async {
            let width = containerView.frame.width
            monthLabel?.frame.origin.x = width * 0.45 + 16
            dayLabel?.frame.origin.x = width * 0.80 + 4
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
        let parent: CustomDatePicker

        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return 2 // 2025, 2026
            case 1: return 12 // 1-12월
            case 2: return daysInMonth(year: parent.selectedYear, month: parent.selectedMonth)
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
            case 0: // 년도
                label.text = "\(2025 + row)"
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)

            case 1: // 월
                label.text = "\(row + 1)"
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)
                label.textAlignment = .left

            case 2: // 일
                label.text = "\(row + 1)"
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)
                label.textAlignment = .left

            default:
                break
            }

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            DispatchQueue.main.async {
                self.parent.makePickerTransparent(pickerView)
            }

            switch component {
            case 0:
                parent.selectedYear = 2025 + row
                pickerView.reloadComponent(2)
            case 1:
                parent.selectedMonth = row + 1
                pickerView.reloadComponent(2)
            case 2:
                parent.selectedDay = row + 1
            default:
                break
            }
        }

        private func daysInMonth(year: Int, month: Int) -> Int {
            let dateComponents = DateComponents(year: year, month: month)
            let date = Calendar.current.date(from: dateComponents)!
            let range = Calendar.current.range(of: .day, in: .month, for: date)!
            return range.count
        }
    }
}
