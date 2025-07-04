//
//  YKFont.swift
//  YakssokDesignSystem
//
//  Created by 김사랑 on 7/4/25.
//

import SwiftUI

/// 약쏙 앱 폰트 시스템
public enum YKFont {

    // MARK: - Header (제목)
    /// 헤더1 - Pretendard SemiBold 28pt
    public static let header1 = Font.custom("Pretendard-SemiBold", size: 28)

    /// 헤더2 - Pretendard SemiBold 24pt
    public static let header2 = Font.custom("Pretendard-SemiBold", size: 24)

    // MARK: - Subheading (서브타이틀)
    /// 서브타이틀1 - Pretendard Bold 18pt
    public static let subtitle1 = Font.custom("Pretendard-Bold", size: 18)

    /// 서브타이틀2 - Pretendard SemiBold 16pt
    public static let subtitle2 = Font.custom("Pretendard-SemiBold", size: 16)

    // MARK: - Body (본문)
    /// 바디0 - Pretendard Medium 16pt
    public static let body0 = Font.custom("Pretendard-Medium", size: 18)

    /// 바디1 - Pretendard Medium 16pt
    public static let body1 = Font.custom("Pretendard-Medium", size: 16)

    /// 바디2 - Pretendard Medium 14pt
    public static let body2 = Font.custom("Pretendard-Medium", size: 14)

    // MARK: - Caption (캡션)
    /// 캡션1 - Pretendard Medium 12pt
    public static let caption1 = Font.custom("Pretendard-Medium", size: 12)
}
