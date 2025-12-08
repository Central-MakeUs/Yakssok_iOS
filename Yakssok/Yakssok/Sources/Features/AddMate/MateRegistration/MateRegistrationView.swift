//
//  MateRegistrationView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MateRegistrationView: View {
    let store: StoreOf<MateRegistrationFeature>

    var body: some View {
        NavigationView {
            ZStack {
                YKColor.Neutral.grey100
                    .ignoresSafeArea(.all)

                WithViewStore(store, observe: { $0 }) { viewStore in
                    YKNavigationBar(
                        title: "메이트 추가",
                        hasBackButton: true,
                        onBackTapped: {
                            viewStore.send(.backButtonTapped)
                        }
                    ) {
                        VStack(spacing: 0) {
                            MateCharactersSection()

                            Spacer()
                                .frame(height: Layout.charactersToInputSpacing)

                            MateCodeInputSection(store: store)
                                .padding(.horizontal, Layout.horizontalPadding)

                            Spacer()
                                .frame(height: 21)

                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: Layout.inputToMyCodeSpacing)

                                MyCodeSection(store: store)

                                Spacer()

                                InitialViewButton(store: store)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, Layout.buttonBottomPadding)
                            }
                            .background(YKColor.Neutral.grey50)
                            .cornerRadius(Layout.myCodeCardCornerRadius, corners: [.topLeft, .topRight])
                            .ignoresSafeArea(.container, edges: .bottom)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .top)
                    .sheet(isPresented: viewStore.binding(
                        get: \.showShareSheet,
                        send: { _ in .dismissShareSheet }
                    )) {
                        ShareSheet(items: [
                            """
                        \(viewStore.currentUserName)님이 함께 약 챙기자고 해요.
                        가끔 잊어버릴 수도 있으니까,
                        서로 약 잘 먹고 있는지 확인하며 챙기는 건 어때요?
                        필요할 땐 잔소리도 살짝😉
                        
                        \(viewStore.currentUserName)님의 코드: \(viewStore.myCode)
                        
                        👇 여기를 들어오면 같이 챙길 수 있어요
                        https://yakssok.onelink.me/ggOB/uvut58xg
                        """
                        ])
                        .presentationDetents([.medium])
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }

                // 성공/에러 메시지 오버레이
                WithViewStore(store, observe: \.showSuccessMessage) { successViewStore in
                    if successViewStore.state {
                        MessageOverlay(
                            message: "내 코드가 복사되었습니다",
                            onDismiss: { store.send(.dismissSuccessMessage) }
                        )
                    }
                }

                WithViewStore(store, observe: \.error) { errorViewStore in
                    if let error = errorViewStore.state {
                        MessageOverlay(
                            message: error,
                            onDismiss: { store.send(.dismissError) }
                        )
                    }
                }

                WithViewStore(store, observe: { $0 }) { viewStore in
                    if viewStore.showCompletionModal, let mateInfo = viewStore.addedMateInfo {
                        MateAddCompletionModalView(
                            mateInfo: mateInfo,
                            onConfirm: {
                                store.send(.completionModalConfirmButtonTapped)
                            }
                        )
                    }
                }
            }
            .onTapGesture {
                // Swift 6에서 권장하는 키보드 내리기 방식
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.endEditing(true)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .top) // NavigationView 전체 상단 고정
    }
}

private struct MateCharactersSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 16)

            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 153)
                    .background(YKColor.Neutral.grey150)
                    .cornerRadius(24)
                    .padding(.horizontal, Layout.horizontalPadding)

                Image("mates")
                    .resizable()
                    .scaledToFit()
                    .padding(.leading, 13)
                    .padding(.trailing, 23)
            }

            Spacer()
                .frame(height: 12)
        }
    }
}

private struct MateCodeInputSection: View {
    let store: StoreOf<MateRegistrationFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: Layout.inputSectionSpacing) {
                Text("메이트 코드 입력")
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey950)

                MateCodeInputField(
                    text: viewStore.binding(
                        get: \.mateCode,
                        send: { .mateCodeChanged($0) }
                    ),
                    isEnabled: !viewStore.isLoading,
                    isAddButtonEnabled: viewStore.isAddButtonEnabled,
                    onAddTapped: {
                        viewStore.send(.addMateButtonTapped)
                    }
                )
            }
        }
    }
}

private struct MateCodeInputField: View {
    @Binding var text: String
    let isEnabled: Bool
    let isAddButtonEnabled: Bool
    let onAddTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("코드입력")
                        .font(YKFont.body1)
                        .foregroundColor(YKColor.Neutral.grey400)
                        .padding(.leading, Layout.textFieldPadding)
                }

                TextField("", text: $text)
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .disabled(!isEnabled)
                    .padding(.leading, Layout.textFieldPadding)
                    .padding(.vertical, Layout.textFieldVerticalPadding)
            }

            Button(action: onAddTapped) {
                Text("추가")
                    .font(YKFont.body1)
                    .foregroundColor(addButtonTextColor)
                    .padding(.horizontal, Layout.addButtonHorizontalPadding)
                    .padding(.vertical, Layout.addButtonVerticalPadding)
                    .background(addButtonBackgroundColor)
                    .cornerRadius(Layout.addButtonCornerRadius)
            }
            .disabled(!isAddButtonEnabled || !isEnabled)
            .padding(.trailing, 12)
            .padding(.vertical, 10)
        }
        .background(YKColor.Neutral.grey50)
        .cornerRadius(Layout.textFieldCornerRadius)
    }

    private var addButtonTextColor: Color {
        isAddButtonEnabled ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400
    }

    private var addButtonBackgroundColor: Color {
        isAddButtonEnabled ? YKColor.Neutral.grey900 : YKColor.Neutral.grey200
    }
}

private struct MyCodeSection: View {
    let store: StoreOf<MateRegistrationFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Text("내 코드 알려주고,\n팔로우 요청해보세요!")
                    .font(YKFont.body1)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 32)

                Text("내 코드 복사")
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .padding(.bottom, 9)

                MyCodeCard(
                    code: viewStore.myCode,
                    onCopyTapped: {
                        viewStore.send(.copyMyCodeTapped)
                    }
                )
                .padding(.horizontal, 48)
            }
        }
    }
}

private struct MyCodeCard: View {
    let code: String
    let onCopyTapped: () -> Void

    var body: some View {
        Button(action: onCopyTapped) {
            HStack(alignment: .center) {
                Spacer()
                Text(code)
                    .font(YKFont.body0)
                    .foregroundColor(YKColor.Neutral.grey950)
                    .underline(true, pattern: .solid)
                Spacer()
            }
            .padding(16)
            .frame(height: 56, alignment: .center)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(YKColor.Neutral.grey400, style: StrokeStyle(lineWidth: 1, dash: [8, 8]))
            )
        }
        .background(YKColor.Neutral.grey50)
        .cornerRadius(16)
    }
}

private struct InitialViewButton: View {
    let store: StoreOf<MateRegistrationFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button(action: {
                viewStore.send(.shareInviteTapped)
            }) {
                Text("내 코드 공유하기")
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey50)
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.initialViewButtonHeight)
                    .background(YKColor.Primary.primary400)
                    .cornerRadius(Layout.initialViewButtonCornerRadius)
            }
        }
    }
}

private struct MessageOverlay: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 16) {
                Text(message)
                    .font(YKFont.subtitle2)
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(YKColor.Neutral.grey900)
            .cornerRadius(12)
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss()
            }
        }
    }
}

private struct MateAddCompletionModalView: View {
    let mateInfo: MateRegistrationFeature.State.AddedMateInfo
    let onConfirm: () -> Void

    var body: some View {
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

                    HStack(spacing: 8) {
                        Text("\(mateInfo.name)님과 메이트가 되었어요!")
                            .font(YKFont.subtitle1)
                            .foregroundColor(YKColor.Neutral.grey900)
                        Image("hands-up")
                            .frame(width: 24, height: 24)
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 20)
                    .padding(.top, 28)

                    MateInfoCardView(mateInfo: mateInfo)
                        .padding(.horizontal, 16)

                    Spacer()
                        .frame(height: 60)

                    Button(action: {
                        onConfirm()
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

private struct MateInfoCardView: View {
    let mateInfo: MateRegistrationFeature.State.AddedMateInfo

    var body: some View {
        HStack(spacing: 8) {
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
                } else {
                    Image("default-profile-1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())

            // 이름
            VStack(alignment: .leading, spacing: 4) {
                Text(mateInfo.name)
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey600)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 32
    static let topSpacing: CGFloat = 35
    static let charactersHeight: CGFloat = 115
    static let charactersSpacing: CGFloat = 20
    static let charactersToInputSpacing: CGFloat = 12
    static let inputToMyCodeSpacing: CGFloat = 44
    static let buttonBottomPadding: CGFloat = 50

    static let inputSectionSpacing: CGFloat = 6
    static let inputFieldSpacing: CGFloat = 8
    static let textFieldPadding: CGFloat = 16
    static let textFieldVerticalPadding: CGFloat = 16
    static let textFieldCornerRadius: CGFloat = 16
    static let addButtonHorizontalPadding: CGFloat = 16
    static let addButtonVerticalPadding: CGFloat = 12
    static let addButtonCornerRadius: CGFloat = 12

    static let myCodeSectionSpacing: CGFloat = 16
    static let myCodeCardSpacing: CGFloat = 8
    static let myCodeCardVerticalPadding: CGFloat = 32
    static let myCodeCardCornerRadius: CGFloat = 32

    static let initialViewButtonHeight: CGFloat = 56
    static let initialViewButtonCornerRadius: CGFloat = 16
}
