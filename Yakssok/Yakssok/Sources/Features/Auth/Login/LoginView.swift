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

    private let logoTopSpacing: CGFloat = 257
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
                        .frame(width: 91, height: 79)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 5) {
                            viewStore.send(.logoLongPressed)
                        }
                        .padding(.top, logoTopSpacing)

                    Spacer()

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

                        // 마스터 모드가 활성화되면 마스터 로그인 버튼 표시
                        if viewStore.isMasterModeEnabled {
                            LoginButton(
                                title: "마스터 계정으로 로그인",
                                iconName: "key",
                                backgroundColor: YKColor.Primary.primary400,
                                titleColor: YKColor.Neutral.grey50
                            ) {
                                viewStore.send(.masterLoginTapped)
                            }
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: viewStore.isMasterModeEnabled)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, bottomPadding)
                }
            }

            .overlay(
                Group {
                    if viewStore.isLoading {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: YKColor.Primary.primary400))
                            .scaleEffect(1.5)
                    }
                }
            )
            .alert(
                "마스터 모드",
                isPresented: Binding(
                    get: { viewStore.showMasterPasswordAlert },
                    set: { _ in }
                )
            ) {
                SecureField("비밀번호", text: Binding(
                    get: { viewStore.masterPassword },
                    set: { viewStore.send(.masterPasswordChanged($0)) }
                ))

                Button("확인") {
                    viewStore.send(.masterLoginConfirmed)
                }

                Button("취소", role: .cancel) {
                    viewStore.send(.masterLoginCancelled)
                }
            } message: {
                Text("마스터 계정 비밀번호를 입력하세요.")
            }

            .alert(
                "로그인 오류",
                isPresented: Binding(
                    get: { viewStore.error != nil },
                    set: { _ in }
                )
            ) {
                Button("확인") {
                }
            } message: {
                if let error = viewStore.error {
                    Text(error)
                }
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
                    // 시스템 아이콘인 경우와 이미지 파일인 경우 구분
                    if iconName == "key" {
                        Image(systemName: "key.fill")
                            .font(.system(size: 20))
                            .foregroundColor(titleColor)
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                    }
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
