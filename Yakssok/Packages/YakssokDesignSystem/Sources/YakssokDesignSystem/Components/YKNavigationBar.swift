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

    public init(
        title: String,
        hasBackButton: Bool = false,
        onBackTapped: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.hasBackButton = hasBackButton
        self.onBackTapped = onBackTapped
        self.content = content()
    }

    public var body: some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: hasBackButton ?
                Button {
                    onBackTapped?()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(YKColor.Neutral.grey900)
                }
                    .accessibilityLabel("뒤로가기") :
                    nil
            )
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.shadowColor = .clear
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor(YKColor.Neutral.grey900)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}
