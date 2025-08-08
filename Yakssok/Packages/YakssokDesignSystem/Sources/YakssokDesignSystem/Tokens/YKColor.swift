//
//  YKColor.swift
//  YakssokDesignSystem
//
//  Created by 김사랑 on 7/4/25.
//

import SwiftUI

/// 약쏙 앱 컬러 토큰 시스템
public struct YKColor {

    // MARK: - Neutral Colors (그레이 스케일)
    public struct Neutral {
        public static let grey50 = Color(hex: "#F8F8F8")
        public static let grey100 = Color(hex: "#EFEFEF")
        public static let grey150 = Color(hex: "#E9E9E9")
        public static let grey200 = Color(hex: "#DCDCDC")
        public static let grey300 = Color(hex: "#BDBDBD")
        public static let grey400 = Color(hex: "#989898")
        public static let grey500 = Color(hex: "#7C7C7C")
        public static let grey600 = Color(hex: "#656565")
        public static let grey700 = Color(hex: "#525252")
        public static let grey800 = Color(hex: "#464646")
        public static let grey900 = Color(hex: "#3D3D3D")
        public static let grey950 = Color(hex: "#202020")
    }

    // MARK: - Primary Colors (메인 오렌지)
    public struct Primary {
        public static let primary50 = Color(hex: "#FFF2ED")
        public static let primary100 = Color(hex: "#FFE3D6")
        public static let primary200 = Color(hex: "#FDC2AB")
        public static let primary300 = Color(hex: "#FB9876")
        public static let primary400 = Color(hex: "#F9623E")
        public static let primary500 = Color(hex: "#F63A18")
        public static let primary600 = Color(hex: "#E7220F")
        public static let primary700 = Color(hex: "#C0140E")
        public static let primary800 = Color(hex: "#981415")
        public static let primary900 = Color(hex: "#7B1313")
        public static let primary950 = Color(hex: "#42080B")
    }

    // MARK: - Sub Colors (보조 색상)
    public struct Sub {
        // Purple
        public static let purple = Color(hex: "#7C24DB")
        // Yellow
        public static let yellow = Color(hex: "#FFB012")
        // Green
        public static let green = Color(hex: "#3ADE4D")
        // Blue
        public static let blue = Color(hex: "#40B0FA")
        // Pink
        public static let pink = Color(hex: "#D224DB")
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b)
    }
}
