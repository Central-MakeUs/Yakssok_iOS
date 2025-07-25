//
//  MyMatesView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MyMatesView: View {
    let store: StoreOf<MyMatesFeature>

    private let profileSize: CGFloat = 64
    private let spacing: CGFloat = 12
    private let selectedBorderWidth: CGFloat = 2

    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    YKColor.Neutral.grey100
                        .ignoresSafeArea(.all)

                    YKNavigationBar(
                        title: "메이트",
                        hasBackButton: true,
                        onBackTapped: {
                            viewStore.send(.backButtonTapped)
                        }
                    ) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 32) {
                                // 팔로잉 섹션
                                VStack(alignment: .leading, spacing: 26) {
                                    Text("팔로잉 \(viewStore.followingUsers.count)명")
                                        .font(YKFont.body1)
                                        .foregroundColor(YKColor.Neutral.grey800)
                                        .padding(.horizontal, 16)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: spacing) {
                                            ForEach(Array(viewStore.followingUsers.enumerated()), id: \.element.id) { index, user in
                                                MateProfileView(
                                                    user: user,
                                                    isSelected: false,
                                                    profileSize: profileSize,
                                                    selectedBorderWidth: selectedBorderWidth
                                                ) {
                                                    viewStore.send(.followingUserSelected(userId: user.id))
                                                }
                                                .padding(.leading, index == 0 ? 16 : 0)
                                            }

                                            // 추가하기 버튼 (팔로잉 섹션에만)
                                            MaPageAddMateButton(profileSize: profileSize) {
                                                viewStore.send(.addMateButtonTapped)
                                            }
                                            .padding(.trailing, 16)
                                        }
                                        .padding(selectedBorderWidth)
                                    }
                                }

                                // 팔로워 섹션
                                VStack(alignment: .leading, spacing: 26) {
                                    Text("팔로워 \(viewStore.followerUsers.count)명")
                                        .font(YKFont.body1)
                                        .foregroundColor(YKColor.Neutral.grey800)
                                        .padding(.horizontal, 16)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: spacing) {
                                            ForEach(Array(viewStore.followerUsers.enumerated()), id: \.element.id) { index, user in
                                                MateProfileView(
                                                    user: user,
                                                    isSelected: false,
                                                    profileSize: profileSize,
                                                    selectedBorderWidth: selectedBorderWidth
                                                ) {
                                                }
                                                .padding(.leading, index == 0 ? 16 : 0)
                                            }
                                        }
                                        .padding(selectedBorderWidth)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.top, 18)
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    store.send(.onAppear)
                }
            }
        }
    }
}


struct MaPageAddMateButton: View {
    let profileSize: CGFloat
    let action: () -> Void

    private let iconPadding: CGFloat = 14
    private let textSpacing: CGFloat = 8

    var body: some View {
        VStack(spacing: textSpacing) {
            Button(action: action) {
                Circle()
                    .fill(YKColor.Neutral.grey150)
                    .frame(width: profileSize, height: profileSize)
                    .overlay {
                        Image("profile-plus-small")
                            .padding(iconPadding)
                    }
            }
            Text("")
                .font(YKFont.body2)
        }
    }
}
