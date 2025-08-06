//
//  MyPageView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MyPageView: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    YKColor.Neutral.grey100
                        .ignoresSafeArea(.all)

                    YKNavigationBar(
                        title: "",
                        hasBackButton: true,
                        onBackTapped: {
                            viewStore.send(.backButtonTapped)
                        }
                    ) {
                        VStack(spacing: 0) {
                            ProfileSection(store: store)
                                .padding(.bottom, Layout.profileToStatsSpacing)

                            StatsSection(store: store)
                                .padding(.bottom, Layout.statsToMenuSpacing)

                            MenuSection(store: store)
                                .padding(.bottom, Layout.menuToVersionSpacing)

                            VersionSection(store: store)

                            Spacer()

                            BottomButtonsSection(store: store)

                            Spacer()
                                .frame(height: Layout.bottomSpacing)
                        }
                        .ignoresSafeArea(.container, edges: .bottom)
                        .padding(.horizontal, Layout.horizontalPadding)
                    }

                    IfLetStore(store.scope(state: \.myMedicines, action: \.myMedicines)) { myMedicinesStore in
                        MyMedicinesView(store: myMedicinesStore)
                    }
                    IfLetStore(store.scope(state: \.myMates, action: \.myMates)) { myMatesStore in
                        MyMatesView(store: myMatesStore)
                    }
                    IfLetStore(store.scope(state: \.profileEdit, action: \.profileEdit)) { profileEditStore in
                        ProfileEditView(store: profileEditStore)
                    }
                    IfLetStore(store.scope(state: \.logoutModal, action: \.logoutModal)) { logoutStore in
                        LogoutModalView(store: logoutStore)
                    }
                    IfLetStore(store.scope(state: \.withdrawalModal, action: \.withdrawalModal)) { withdrawalStore in
                        WithdrawalModalView(store: withdrawalStore)
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .sheet(isPresented: viewStore.binding(
                    get: \.showPrivacyPolicy,
                    send: { _ in .dismissPrivacyPolicy }
                )) {
                    WebView(url: URL(string: "https://www.notion.so/2351221cc28180ebbd2ff7f6feefd0e0")!)
                }
                .sheet(isPresented: viewStore.binding(
                    get: \.showTermsOfUse,
                    send: { _ in .dismissTermsOfUse }
                )) {
                    WebView(url: URL(string: "https://www.notion.so/2351221cc2818066b34ec4ee545031f9")!)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private struct ProfileSection: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: Layout.profileSpacing) {
                // 프로필 이미지
                Group {
                    if let profileImage = viewStore.userProfile?.profileImage {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            // 카카오 계정 기본 프로필 또는 기본 이미지
                            Image("default-profile-1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                        .clipShape(Circle())
                    } else {
                        // 가입 시 카카오 계정 프로필 사진이 디폴트 값
                        Image("default-profile-1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                    }
                }

                // 닉네임
                Text(viewStore.userProfile?.name ?? "사용자")
                    .font(YKFont.header2)
                    .foregroundColor(YKColor.Neutral.grey900)

                Spacer()

                // 프로필 변경 버튼 - 프로필 화면으로 링크
                Button(action: {
                    viewStore.send(.profileEditTapped)
                }) {
                    HStack(spacing: 4) {
                        Text("프로필 변경")
                            .font(YKFont.body2)
                            .foregroundColor(YKColor.Neutral.grey600)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(YKColor.Neutral.grey400)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(YKColor.Neutral.grey200, lineWidth: 1)
                    )
                }
            }
            .padding(.top, Layout.topSpacing)
        }
    }
}

private struct StatsSection: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 0) {
                // 내 복용약
                StatCard(
                    count: viewStore.medicineCount,
                    title: "내 복용약",
                    backgroundColor: YKColor.Primary.primary400,
                    stickerImage: "medicine-sticker",
                    cardType: .medicine
                ) {
                    viewStore.send(.myMedicinesTapped)
                }

                StitchLine()

                // 내 메이트
                StatCard(
                    count: viewStore.mateCount,
                    title: "내 메이트",
                    backgroundColor: YKColor.Primary.primary400,
                    stickerImage: "mate-sticker",
                    cardType: .mate
                ) {
                    viewStore.send(.myMatesTapped)
                }
            }
        }
    }
}

private struct StatCard: View {
    let count: Int
    let title: String
    let backgroundColor: Color
    let stickerImage: String
    let cardType: CardType
    let onTap: () -> Void

    enum CardType {
        case medicine
        case mate

        var unit: String {
            switch self {
            case .medicine:
                return "개"
            case .mate:
                return "명"
            }
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count)\(cardType.unit)")
                        .font(YKFont.header1)
                        .foregroundColor(YKColor.Neutral.grey50)

                    HStack(spacing: 4) {
                        Text(title)
                            .font(YKFont.body2)
                            .foregroundColor(YKColor.Primary.primary100)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(YKColor.Primary.primary100)
                    }
                }

                Spacer()

                Image(stickerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(20)
        }
    }
}

private struct StitchLine: View {
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<10, id: \.self) { index in
                Rectangle()
                    .fill(index % 2 == 0 ? YKColor.Primary.primary400 : YKColor.Neutral.grey100)
                    .frame(width: 2, height: 4)
            }
        }
    }
}

private struct MenuSection: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.menuItemSpacing) {
                // 개인정보 정책 화면으로 링크
                MenuRow(
                    iconImage: "policy",
                    title: "개인정보 정책",
                    onTap: { viewStore.send(.personalInfoPolicyTapped) }
                )

                // 이용약관 화면으로 링크
                MenuRow(
                    iconImage: "terms",
                    title: "이용약관",
                    onTap: { viewStore.send(.termsOfUseTapped) }
                )
            }
        }
    }
}

private struct MenuRow: View {
    let iconImage: String
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey900)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(YKColor.Neutral.grey400)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(YKColor.Neutral.grey150)
            .cornerRadius(12)
        }
    }
}

private struct VersionSection: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text("앱 버전")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey900)

                Spacer()

                Text(viewStore.appVersion)
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey500)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(YKColor.Neutral.grey200, lineWidth: 1)
            )
        }
    }
}

private struct BottomButtonsSection: View {
    let store: StoreOf<MyPageFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 0) {
                // 로그아웃 버튼
                Button(action: {
                    viewStore.send(.logoutTapped)
                }) {
                    Text("로그아웃")
                        .font(YKFont.body2)
                        .foregroundColor(YKColor.Neutral.grey500)
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.clear)

                Rectangle()
                    .fill(YKColor.Neutral.grey300)
                    .frame(width: 1, height: 40)

                // 회원탈퇴 버튼
                Button(action: {
                    viewStore.send(.withdrawalTapped)
                }) {
                    Text("회원탈퇴")
                        .font(YKFont.body2)
                        .foregroundColor(YKColor.Neutral.grey500)
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.clear)
            }
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let topSpacing: CGFloat = 16
    static let profileSpacing: CGFloat = 8
    static let profileImageSize: CGFloat = 52
    static let profileToStatsSpacing: CGFloat = 20
    static let statsSpacing: CGFloat = 8
    static let statsToMenuSpacing: CGFloat = 32
    static let menuItemSpacing: CGFloat = 8
    static let menuToVersionSpacing: CGFloat = 16
    static let bottomButtonSpacing: CGFloat = 8
    static let bottomSpacing: CGFloat = 50
}
