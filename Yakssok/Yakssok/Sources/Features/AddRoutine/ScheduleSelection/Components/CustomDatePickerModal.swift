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
                            selectedDay: $selectedDay,
                            isSelectingStartDate: viewStore.isSelectingStartDate,
                            startDate: viewStore.startDate
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
}

struct CustomDatePicker: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int
    let isSelectingStartDate: Bool
    let startDate: Date

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

        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)

        let minYear = todayComponents.year ?? 2025
        let yearOffset = selectedYear - minYear

        picker.selectRow(yearOffset, inComponent: 0, animated: false)
        picker.selectRow(selectedMonth - 1, inComponent: 1, animated: false)

        let availableDays = getAvailableDays(year: selectedYear, month: selectedMonth)
        if !availableDays.isEmpty {
            let firstAvailableDay = availableDays.first!
            let dayIndex = max(0, min(selectedDay - firstAvailableDay, availableDays.count - 1))
            picker.selectRow(dayIndex, inComponent: 2, animated: false)
        } else {
            picker.selectRow(0, inComponent: 2, animated: false)
        }

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

        for subview in picker.subviews {
            if String(describing: type(of: subview)).contains("PickerTable") {
                continue
            }

            if subview is UILabel {
                continue
            }

            if subview.frame.height <= 3 {
                continue
            }

            subview.backgroundColor = UIColor.clear
            makeSubviewsTransparent(subview)
        }
    }

    private func makeSubviewsTransparent(_ view: UIView) {
        for subview in view.subviews {
            if subview is UILabel || String(describing: type(of: subview)).contains("PickerTable") {
                continue
            }

            if subview.frame.height <= 3 {
                continue
            }

            subview.backgroundColor = UIColor.clear
            makeSubviewsTransparent(subview)
        }
    }

    private func getAvailableDays(year: Int, month: Int) -> [Int] {
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)

        let totalDaysInMonth = {
            let dateComponents = DateComponents(year: year, month: month)
            guard let date = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: date) else {
                return 30
            }
            return range.count
        }()

        let currentYear = todayComponents.year ?? Calendar.current.component(.year, from: Date())
        let currentMonth = todayComponents.month ?? Calendar.current.component(.month, from: Date())
        let currentDay = todayComponents.day ?? Calendar.current.component(.day, from: Date())

        if isSelectingStartDate {
            if year == currentYear && month == currentMonth {
                return Array(currentDay...totalDaysInMonth)
            } else if year > currentYear || (year == currentYear && month > currentMonth) {
                return Array(1...totalDaysInMonth)
            } else {
                return []
            }
        } else {
            let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
            let startYear = startComponents.year ?? currentYear
            let startMonth = startComponents.month ?? currentMonth
            let startDay = startComponents.day ?? currentDay

            if year == startYear && month == startMonth {
                return Array(startDay...totalDaysInMonth)
            } else if year > startYear || (year == startYear && month > startMonth) {
                return Array(1...totalDaysInMonth)
            } else {
                return []
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
            let today = Date()
            let calendar = Calendar.current
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            let currentYear = todayComponents.year ?? Calendar.current.component(.year, from: Date())
            let currentMonth = todayComponents.month ?? Calendar.current.component(.month, from: Date())

            switch component {
            case 0:
                return 2
            case 1:
                if parent.selectedYear == currentYear && parent.isSelectingStartDate {
                    return 12 - currentMonth + 1
                } else if !parent.isSelectingStartDate {
                    let startComponents = calendar.dateComponents([.year, .month, .day], from: parent.startDate)
                    let startYear = startComponents.year ?? currentYear
                    let startMonth = startComponents.month ?? currentMonth
                    if parent.selectedYear == startYear {
                        return 12 - startMonth + 1
                    }
                }
                return 12
            case 2:
                let availableDays = parent.getAvailableDays(year: parent.selectedYear, month: parent.selectedMonth)
                return availableDays.count
            default:
                return 0
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

            let today = Date()
            let calendar = Calendar.current
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            let currentYear = todayComponents.year ?? Calendar.current.component(.year, from: Date())
            let currentMonth = todayComponents.month ?? Calendar.current.component(.month, from: Date())

            switch component {
            case 0:
                label.text = "\(currentYear + row)"
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)

            case 1:
                if parent.selectedYear == currentYear && parent.isSelectingStartDate {
                    label.text = "\(currentMonth + row)"
                } else if !parent.isSelectingStartDate {
                    let startComponents = calendar.dateComponents([.year, .month, .day], from: parent.startDate)
                    let startYear = startComponents.year ?? currentYear
                    let startMonth = startComponents.month ?? currentMonth
                    if parent.selectedYear == startYear {
                        label.text = "\(startMonth + row)"
                    } else {
                        label.text = "\(row + 1)"
                    }
                } else {
                    label.text = "\(row + 1)"
                }
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)
                label.textAlignment = .left

            case 2:
                let availableDays = parent.getAvailableDays(year: parent.selectedYear, month: parent.selectedMonth)
                if row < availableDays.count {
                    label.text = "\(availableDays[row])"
                } else {
                    label.text = ""
                }
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.textColor = UIColor(YKColor.Neutral.grey950)
                label.textAlignment = .left

            default:
                break
            }

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let today = Date()
            let calendar = Calendar.current
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            let currentYear = todayComponents.year ?? Calendar.current.component(.year, from: Date())
            let currentMonth = todayComponents.month ?? Calendar.current.component(.month, from: Date())

            switch component {
            case 0:
                parent.selectedYear = currentYear + row

                if parent.selectedYear == currentYear && parent.isSelectingStartDate {
                    if parent.selectedMonth < currentMonth {
                        parent.selectedMonth = currentMonth
                    }
                } else if !parent.isSelectingStartDate {
                    let startComponents = calendar.dateComponents([.year, .month, .day], from: parent.startDate)
                    let startYear = startComponents.year ?? currentYear
                    let startMonth = startComponents.month ?? currentMonth
                    if parent.selectedYear == startYear && parent.selectedMonth < startMonth {
                        parent.selectedMonth = startMonth
                    }
                }

                DispatchQueue.main.async {
                    pickerView.reloadComponent(1)
                    pickerView.reloadComponent(2)

                    let monthIndex: Int
                    if self.parent.selectedYear == currentYear && self.parent.isSelectingStartDate {
                        monthIndex = self.parent.selectedMonth - currentMonth
                    } else if !self.parent.isSelectingStartDate {
                        let startComponents = calendar.dateComponents([.year, .month, .day], from: self.parent.startDate)
                        let startYear = startComponents.year ?? currentYear
                        let startMonth = startComponents.month ?? currentMonth
                        if self.parent.selectedYear == startYear {
                            monthIndex = self.parent.selectedMonth - startMonth
                        } else {
                            monthIndex = self.parent.selectedMonth - 1
                        }
                    } else {
                        monthIndex = self.parent.selectedMonth - 1
                    }
                    pickerView.selectRow(max(0, monthIndex), inComponent: 1, animated: false)

                    let availableDays = self.parent.getAvailableDays(year: self.parent.selectedYear, month: self.parent.selectedMonth)
                    if !availableDays.isEmpty {
                        if availableDays.contains(self.parent.selectedDay) {
                            let dayIndex = availableDays.firstIndex(of: self.parent.selectedDay) ?? 0
                            pickerView.selectRow(dayIndex, inComponent: 2, animated: false)
                        } else {
                            self.parent.selectedDay = availableDays.first!
                            pickerView.selectRow(0, inComponent: 2, animated: false)
                        }
                    } else {
                        pickerView.selectRow(0, inComponent: 2, animated: false)
                    }
                }

            case 1:
                if parent.selectedYear == currentYear && parent.isSelectingStartDate {
                    parent.selectedMonth = currentMonth + row
                } else if !parent.isSelectingStartDate {
                    let startComponents = calendar.dateComponents([.year, .month, .day], from: parent.startDate)
                    let startYear = startComponents.year ?? currentYear
                    let startMonth = startComponents.month ?? currentMonth
                    if parent.selectedYear == startYear {
                        parent.selectedMonth = startMonth + row
                    } else {
                        parent.selectedMonth = row + 1
                    }
                } else {
                    parent.selectedMonth = row + 1
                }

                DispatchQueue.main.async {
                    pickerView.reloadComponent(2)

                    let availableDays = self.parent.getAvailableDays(year: self.parent.selectedYear, month: self.parent.selectedMonth)
                    if !availableDays.isEmpty {
                        if availableDays.contains(self.parent.selectedDay) {
                            let dayIndex = availableDays.firstIndex(of: self.parent.selectedDay) ?? 0
                            pickerView.selectRow(dayIndex, inComponent: 2, animated: false)
                        } else {
                            self.parent.selectedDay = availableDays.first!
                            pickerView.selectRow(0, inComponent: 2, animated: false)
                        }
                    } else {
                        pickerView.selectRow(0, inComponent: 2, animated: false)
                    }
                }

            case 2:
                let availableDays = parent.getAvailableDays(year: parent.selectedYear, month: parent.selectedMonth)
                if row < availableDays.count {
                    parent.selectedDay = availableDays[row]
                }

            default:
                break
            }
        }
    }
}
