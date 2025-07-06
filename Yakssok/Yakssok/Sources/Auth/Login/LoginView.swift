//
//  LoginView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    private let logoTopSpacing: CGFloat = 254
    private let logoBottomSpacing: CGFloat = 400
    private let buttonSpacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16
    private let bottomPadding: CGFloat = 16

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                YKColor.Neutral.grey50
                    .ignoresSafeArea()
                VStack {
                    Image("logo-login")
                        .resizable()
                        .scaledToFit()
                }
                .padding(.top, logoTopSpacing)
                .padding(.bottom, logoBottomSpacing)
                VStack(spacing: buttonSpacing) {
                    LoginButton(
                        title: "카카오로 계속하기",
                        iconName: "kakao",
                        backgroundColor: Color(red: 0.992, green: 0.863, blue: 0.247),
                        titleColor: YKColor.Neutral.grey950
                    ) {
                        viewStore.send(.kakaoLoginTapped)
                    }
                    LoginButton(
                        title: "Apple로 계속하기",
                        iconName: "apple",
                        backgroundColor: YKColor.Neutral.grey950,
                        titleColor: YKColor.Neutral.grey50
                    ) {
                        viewStore.send(.appleLoginTapped)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, bottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct LoginButton: View {
    let title: String
    let iconName: String
    let backgroundColor: Color
    let titleColor: Color
    let action: () -> Void

    private let height: CGFloat = 56
    private let cornerRadius: CGFloat = 12
    private let iconPadding: CGFloat = 16

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(YKFont.body1)
                    .foregroundColor(titleColor)
                HStack {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }
                .padding(.leading, iconPadding)
                .padding(.vertical, iconPadding)
            }
            .frame(height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
    }
}
