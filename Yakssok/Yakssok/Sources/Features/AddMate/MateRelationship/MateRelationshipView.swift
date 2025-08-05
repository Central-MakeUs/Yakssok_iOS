//
//  MateRelationshipView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MateRelationshipView: View {
    let store: StoreOf<MateRelationshipFeature>

    var body: some View {
        ZStack {
            YKColor.Neutral.grey100
                .ignoresSafeArea(.all)

            WithViewStore(store, observe: { $0 }) { viewStore in
                YKNavigationBar(
                    title: "",
                    hasBackButton: true,
                    onBackTapped: {
                        viewStore.send(.backButtonTapped)
                    }
                ) {
                    VStack(spacing: 0) {
                        MateProfileSection(mateInfo: viewStore.mateInfo)

                        Spacer()
                            .frame(height: Layout.profileToQuestionSpacing)

                        QuestionSection()

                        Spacer()
                            .frame(height: Layout.questionToInputSpacing)

                        RelationshipInputSection(store: store)

                        Spacer()

                        MateAddButton(store: store)
                            .padding(.bottom, Layout.buttonBottomPadding)
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                    .padding(.horizontal, Layout.horizontalPadding)
                }
            }

            // 완료 모달
            WithViewStore(store, observe: \.showCompletionModal) { modalViewStore in
                if modalViewStore.state {
                    MateAddCompletionModal(store: store)
                }
            }
        }
    }
}

private struct MateProfileSection: View {
    let mateInfo: MateRelationshipFeature.State.MateInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: Layout.topSpacing)
            VStack(spacing: Layout.profileSectionSpacing) {
                HStack {
                    Group {
                        if let profileImageName = mateInfo.profileImage {
                            AsyncImage(url: URL(string: profileImageName)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image("default-profile-1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                        } else {
                            Image("default-profile-1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }

                HStack {
                    Text(mateInfo.name)
                        .font(YKFont.body2)
                        .foregroundColor(YKColor.Neutral.grey600)
                        .frame(width: Layout.profileImageSize, alignment: .center)
                    Spacer()
                }
            }
        }
    }
}

private struct QuestionSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.questionSpacing) {
            HStack {
                Text("위 약쏙 메이트와\n어떤 관계인가요?")
                    .font(YKFont.header2)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                Spacer()
            }

            HStack {
                Text("내가 이 사람을 칭하고 싶은 말을 적어주세요!")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey600)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
    }
}

private struct RelationshipInputSection: View {
    let store: StoreOf<MateRelationshipFeature>
    @State private var localRelationship: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    placeholderView
                    inputFieldView(viewStore: viewStore)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(YKColor.Neutral.grey50)
                .cornerRadius(16)
            }
            .onAppear {
                localRelationship = viewStore.relationship
            }
        }
    }
    private var placeholderView: some View {
        Group {
            if localRelationship.isEmpty {
                HStack {
                    Text("내친구, 울엄마 등")
                        .font(YKFont.body1)
                        .foregroundColor(YKColor.Neutral.grey400)
                    Spacer()
                }
            }
        }
    }

    private func inputFieldView(viewStore: ViewStoreOf<MateRelationshipFeature>) -> some View {
        HStack {
            TextField("", text: $localRelationship)
                .onChange(of: localRelationship) { oldValue, newValue in
                    if newValue.count > 5 {
                        localRelationship = String(newValue.prefix(5))
                    }
                    viewStore.send(.relationshipChanged(localRelationship))
                }
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey950)

            counterAndClearButton(viewStore: viewStore)
        }
    }

    private func counterAndClearButton(viewStore: ViewStoreOf<MateRelationshipFeature>) -> some View {
        HStack(spacing: 12) {
            Text("\(localRelationship.count)/5")
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey400)

            if !localRelationship.isEmpty {
                Button(action: {
                    localRelationship = ""
                    viewStore.send(.relationshipChanged(""))
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(YKColor.Neutral.grey500)
                }
            }
        }
    }
}

private struct MateAddButton: View {
    let store: StoreOf<MateRelationshipFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button(action: {
                viewStore.send(.addMateButtonTapped)
            }) {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 20)
                } else {
                    Text("메이트 추가")
                        .font(YKFont.subtitle2)
                        .foregroundColor(buttonTextColor(isEnabled: viewStore.isAddButtonEnabled))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(buttonBackgroundColor(isEnabled: viewStore.isAddButtonEnabled))
            .cornerRadius(Layout.buttonCornerRadius)
            .disabled(!viewStore.isAddButtonEnabled || viewStore.isLoading)
        }
    }

    private func buttonTextColor(isEnabled: Bool) -> Color {
        isEnabled ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400
    }

    private func buttonBackgroundColor(isEnabled: Bool) -> Color {
        isEnabled ? YKColor.Primary.primary400 : YKColor.Neutral.grey200
    }
}

private struct MateAddCompletionModal: View {
    let store: StoreOf<MateRelationshipFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        // 핸들바
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 37.44, height: 4)
                            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .cornerRadius(999)
                            .padding(.top, 12)

                        HStack(spacing: 4) {
                            Text("\(viewStore.mateInfo.name)님과 메이트가 되었어요!")
                                .font(YKFont.subtitle1)
                                .foregroundColor(YKColor.Neutral.grey900)
                            Image("hands-up")
                                .frame(width: 24, height: 24)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 20)
                        .padding(.top, 28)

                        // 메이트 정보 카드
                        MateInfoCard(
                            mateInfo: viewStore.mateInfo,
                            relationship: viewStore.relationship
                        )
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 60)

                        // 확인 버튼
                        Button(action: {
                            viewStore.send(.confirmButtonTapped)
                        }) {
                            Text("홈으로")
                                .font(YKFont.subtitle2)
                                .foregroundColor(YKColor.Neutral.grey50)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(YKColor.Primary.primary400)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(YKColor.Neutral.grey50)
                    .cornerRadius(24)
                    .padding(.horizontal, 13.5)
                }
            }
        }
    }
}

private struct MateInfoCard: View {
    let mateInfo: MateRelationshipFeature.State.MateInfo
    let relationship: String

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            // 프로필 이미지
            Group {
                if let profileImageName = mateInfo.profileImage {
                    AsyncImage(url: URL(string: profileImageName)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("default-profile-1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: Layout.modalProfileImageSize, height: Layout.modalProfileImageSize)
                    .clipShape(Circle())
                } else {
                    Image("default-profile-1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Layout.modalProfileImageSize, height: Layout.modalProfileImageSize)
                        .clipShape(Circle())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(relationship)
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey400)

                Text(mateInfo.name)
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey900)
            }

            Spacer()
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let topSpacing: CGFloat = 60

    static let profileSectionSpacing: CGFloat = 8
    static let profileImageSize: CGFloat = 64
    static let profileToQuestionSpacing: CGFloat = 16

    static let questionSpacing: CGFloat = 16
    static let questionToInputSpacing: CGFloat = 60

    static let buttonBottomPadding: CGFloat = 50
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = 16
    static let modalProfileImageSize: CGFloat = 64
}
