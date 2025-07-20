//
//  LogoutModalView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct LogoutModalView: View {
    let store: StoreOf<LogoutModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.showLogoutComplete {
                LogoutCompleteModal(store: store)
            } else {
                LogoutConfirmModal(store: store)
            }
        }
    }
}

private struct LogoutConfirmModal: View {
    let store: StoreOf<LogoutModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { viewStore.send(.cancelTapped) }

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        Text("로그아웃 하시겠습니까?")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 104)

                        HStack(spacing: 8) {
                            Button("취소") { viewStore.send(.cancelTapped) }
                                .frame(height: 56)
                                .frame(maxWidth: .infinity)
                                .background(YKColor.Neutral.grey100)
                                .foregroundColor(YKColor.Neutral.grey500)
                                .cornerRadius(16)

                            Button("로그아웃") { viewStore.send(.logoutTapped) }
                                .frame(height: 56)
                                .frame(maxWidth: .infinity)
                                .background(YKColor.Neutral.grey100)
                                .foregroundColor(YKColor.Neutral.grey500)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(YKColor.Neutral.grey50)
                    .cornerRadius(24)
                    .padding(.horizontal, 13.5)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

private struct LogoutCompleteModal: View {
    let store: StoreOf<LogoutModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        VStack(spacing: 20) {
                            Text("로그아웃 완료")
                                .font(YKFont.subtitle1)
                                .foregroundColor(YKColor.Neutral.grey900)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("다음에 또 봐요 우리 약쏙!")
                                .font(YKFont.body1)
                                .foregroundColor(YKColor.Neutral.grey900)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 60)

                        Button("또 봐요!") { viewStore.send(.logoutCompleteTapped) }
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .font(YKFont.subtitle2)
                            .background(YKColor.Primary.primary400)
                            .foregroundColor(YKColor.Neutral.grey50)
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                    .background(YKColor.Neutral.grey50)
                    .cornerRadius(24)
                    .padding(.horizontal, 13.5)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}
