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
                        // 핸들바
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 37, height: 4)
                            .cornerRadius(2)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        // 제목
                        Text(viewStore.isSelectingStartDate ? "복용 시작 날짜를 설정해주세요" : "복용 종료 날짜를 설정해주세요")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey950)
                            .padding(.bottom, 20)

                        // 커스텀 날짜 피커 (UIKit 사용)
                        CustomDatePicker(
                            selectedYear: $selectedYear,
                            selectedMonth: $selectedMonth,
                            selectedDay: $selectedDay
                        )
                        .frame(height: 200)
                        .background(Color.clear)
                        .overlay(
                            VStack(spacing: 30) {
                                Rectangle()
                                    .fill(YKColor.Primary.primary400)
                                    .frame(height: 1)
                                Rectangle()
                                    .fill(YKColor.Primary.primary400)
                                    .frame(height: 1)
                            }
                        )
                        .padding(.horizontal, 13.5)

                        // 종료일 없음 체크박스 (종료일 선택시만)
                        if !viewStore.isSelectingStartDate {
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("종료일 없음")
                                        .font(YKFont.body2)
                                        .foregroundColor(YKColor.Neutral.grey400)

                                    Button(action: {
                                        viewStore.send(.endDateToggled)
                                    }) {
                                        Image(systemName: viewStore.hasEndDate ? "square" : "checkmark.square.fill")
                                            .foregroundColor(viewStore.hasEndDate ? YKColor.Neutral.grey300 : YKColor.Primary.primary400)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 20)
                            }
                        }

                        Spacer()
                            .frame(height: 40)

                        // 버튼들
                        HStack(spacing: 8) {
                            Button("닫기") {
                                viewStore.send(.datePickerDismissed)
                            }
                            .frame(width: 84, height: 56)
                            .background(YKColor.Neutral.grey100)
                            .foregroundColor(YKColor.Neutral.grey400)
                            .cornerRadius(16)

                            Button("선택") {
                                let components = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
                                if let date = Calendar.current.date(from: components) {
                                    viewStore.send(.dateChanged(date))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(YKColor.Primary.primary400)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
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

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator

        // 완전히 투명하게 만들기
        makePickerTransparent(picker)

        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // 업데이트 시에도 투명 배경 유지
        makePickerTransparent(uiView)

        let yearIndex = selectedYear - 2025
        uiView.selectRow(yearIndex, inComponent: 0, animated: false)
        uiView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        uiView.selectRow(selectedDay - 1, inComponent: 2, animated: false)
    }

    private func makePickerTransparent(_ picker: UIPickerView) {
        picker.backgroundColor = UIColor.clear

        // 배경만 투명하게 하고 텍스트는 보존
        func clearBackgroundOnly(view: UIView) {
            view.backgroundColor = UIColor.clear

            // UILabel은 건드리지 않음 (텍스트 보존)
            if !(view is UILabel) {
                for subview in view.subviews {
                    clearBackgroundOnly(view: subview)
                }
            }
        }

        clearBackgroundOnly(view: picker)

        // 선택 영역의 회색 배경만 제거 (텍스트는 건드리지 않음)
        picker.subviews.forEach { subview in
            // UILabel이 아닌 뷰만 처리
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
                let monthText = "\(row + 1)"
                let unitText = "월"

                let attributedString = NSMutableAttributedString()
                attributedString.append(NSAttributedString(
                    string: monthText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                        .foregroundColor: UIColor(YKColor.Neutral.grey950)
                    ]
                ))
                attributedString.append(NSAttributedString(
                    string: "   " + unitText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor(YKColor.Neutral.grey500)
                    ]
                ))

                label.attributedText = attributedString

            case 2: // 일
                let dayText = "\(row + 1)"
                let unitText = "일"

                let attributedString = NSMutableAttributedString()
                attributedString.append(NSAttributedString(
                    string: dayText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                        .foregroundColor: UIColor(YKColor.Neutral.grey950)
                    ]
                ))
                attributedString.append(NSAttributedString(
                    string: "   " + unitText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor(YKColor.Neutral.grey500)
                    ]
                ))

                label.attributedText = attributedString

            default:
                break
            }

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // 선택 시에도 투명 배경 유지
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
