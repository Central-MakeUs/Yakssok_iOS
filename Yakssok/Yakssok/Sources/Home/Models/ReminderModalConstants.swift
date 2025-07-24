//
//  ReminderModalConstants.swift
//  Yakssok
//
//  Created by 김사랑 on 7/16/25.
//

import Foundation

enum ReminderModalConstants {
    enum Text {
        static func greeting(_ userName: String) -> String {
            return "\(userName)님,"
        }
        static let reminderMessage = "지금 드셔야할 약이에요"
        static let actionButtonTitle = "닫기"
    }

    enum Layout {
        static let modalCornerRadius: CGFloat = 24
        static let modalHorizontalPadding: CGFloat = 12
        static let modalBottomPadding: CGFloat = 50

        static let headerSpacing: CGFloat = 5
        static let headerHorizontalPadding: CGFloat = 16
        static let headerTopPadding: CGFloat = 28
        static let headerBottomPadding: CGFloat = 20

        static let medicineListHorizontalPadding: CGFloat = 16
        static let medicineListBottomPadding: CGFloat = 60
        static let medicineItemSpacing: CGFloat = 12
        static let medicineDotSize: CGFloat = 8
        static let medicineRowHeight: CGFloat = 56
        static let medicineRowHorizontalPadding: CGFloat = 16
        static let medicineRowCornerRadius: CGFloat = 16
        static let maxScrollHeight: CGFloat = 200
        static let infoSpacing: CGFloat = 8

        static let footerButtonHeight: CGFloat = 56
        static let footerButtonCornerRadius: CGFloat = 16
        static let footerHorizontalPadding: CGFloat = 16
        static let footerBottomPadding: CGFloat = 16
    }
}
