//
//  YKNavigationBar.swift
//  YakssokDesignSystem
//
//  Created by 김사랑 on 7/6/25.
//

import SwiftUI

/// 약쏙 앱 네비게이션 바 컴포넌트
public struct YKNavigationBar<Content: View>: View {
    let title: String
    let hasBackButton: Bool
    let onBackTapped: (() -> Void)?
    let content: Content
    let backgroundColor: Color

    public init(
        title: String,
        hasBackButton: Bool = false,
        onBackTapped: (() -> Void)? = nil,
        backgroundColor: Color = YKColor.Neutral.grey100,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.hasBackButton = hasBackButton
        self.onBackTapped = onBackTapped
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public init(
        title: String,
        hasBackButton: Bool = false,
        onBackTapped: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title,
            hasBackButton: hasBackButton,
            onBackTapped: onBackTapped,
            backgroundColor: YKColor.Neutral.grey100,
            content: content
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            navigationBarView

            // 메인 컨텐츠
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
    }

    private var navigationBarView: some View {
        HStack {
            // 왼쪽 버튼 (뒤로가기)
            leftButton

            Spacer()

            // 중앙 타이틀
            centerTitle

            Spacer()

            // 오른쪽 여백
            rightSpacer
        }
        .frame(height: Layout.navigationBarHeight)
        .background(backgroundColor)
    }

    private var leftButton: some View {
        Group {
            if hasBackButton {
                Button(action: {
                    onBackTapped?()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: Layout.backButtonIconSize, weight: .medium))
                        .foregroundColor(YKColor.Neutral.grey900)
                }
                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                .accessibilityLabel("뒤로가기")
                .padding(.leading, Layout.horizontalPadding)
            } else {
                Spacer()
                    .frame(width: Layout.buttonSize + Layout.horizontalPadding)
            }
        }
    }

    private var centerTitle: some View {
        Text(title)
            .font(YKFont.subtitle2)
            .foregroundColor(YKColor.Neutral.grey900)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private var rightSpacer: some View {
        Spacer()
            .frame(width: Layout.buttonSize + Layout.horizontalPadding)
    }
}

private enum Layout {
    static let navigationBarHeight: CGFloat = 56
    static let horizontalPadding: CGFloat = 8
    static let buttonSize: CGFloat = 44
    static let backButtonIconSize: CGFloat = 18
}
