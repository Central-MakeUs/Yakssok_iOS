//
//  OnboardingView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    @State private var localNickname: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            YKNavigationBar(
                title: "",
                hasBackButton: true,
                onBackTapped: {
                    viewStore.send(.backToLogin)
                }
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    // 안내 텍스트
                    Text(instructionText)
                        .font(YKFont.header2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(YKColor.Neutral.grey950)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // 텍스트 필드
                    VStack(alignment: .leading, spacing: 8) {
                        textFieldView(viewStore: viewStore)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    Spacer()

                    // 시작하기 버튼
                    Button(action: {
                        if viewStore.isButtonEnabled {
                            viewStore.send(.startButtonTapped)
                        }
                    }) {
                        Text("시작하기")
                            .font(YKFont.subtitle2)
                            .foregroundColor(viewStore.isButtonEnabled ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(viewStore.isButtonEnabled ? YKColor.Primary.primary400 : YKColor.Neutral.grey200)
                            .cornerRadius(16)
                    }
                    .disabled(!viewStore.isButtonEnabled)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(YKColor.Neutral.grey50)
            }
            .navigationBarHidden(true)
        }
    }

    private var instructionText: AttributedString {
        var text = AttributedString("약쏙에서 사용할 닉네임을 작성해보아요!")

        if let range = text.range(of: "닉네임") {
            text[range].foregroundColor = YKColor.Primary.primary400
            text[range].font = YKFont.header2
        }
        return text
    }

    private func textFieldView(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
        ZStack {
            placeholderView
            inputFieldView(viewStore: viewStore)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(YKColor.Neutral.grey50)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(YKColor.Neutral.grey200, lineWidth: 1)
        )
    }

    private var placeholderView: some View {
        Group {
            if localNickname.isEmpty {
                HStack {
                    Text("닉네임")
                        .font(YKFont.body1)
                        .foregroundColor(YKColor.Neutral.grey400)
                    Spacer()
                }
            }
        }
    }

    private func inputFieldView(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
        HStack {
            textField(viewStore: viewStore)
            counterAndClearButton(viewStore: viewStore)
        }
    }

    private func textField(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
        TextField("", text: $localNickname)
            .onChange(of: localNickname) { oldValue, newValue in
                if newValue.count > 5 {
                    localNickname = String(newValue.prefix(5))
                }
                viewStore.send(.nicknameChanged(localNickname))
            }
            .onAppear {
                localNickname = viewStore.nickname
            }
            .font(YKFont.body1)
            .foregroundColor(YKColor.Neutral.grey950)
    }

    private func counterAndClearButton(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
        HStack(spacing: 12) {
            Text("\(localNickname.count)/5")
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey400)
            if !localNickname.isEmpty {
                clearButton(viewStore: viewStore)
            }
        }
    }

    private func clearButton(viewStore: ViewStoreOf<OnboardingFeature>) -> some View {
        Button(action: {
            localNickname = ""
            viewStore.send(.nicknameChanged(""))
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(YKColor.Neutral.grey500)
        }
    }
}
