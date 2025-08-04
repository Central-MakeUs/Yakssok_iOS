//
//  ProfileEditView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct ProfileEditView: View {
    let store: StoreOf<ProfileEditFeature>
    @State private var localNickname: String = ""
    
    var body: some View {
       WithViewStore(store, observe: { $0 }) { viewStore in
           ZStack {
               YKColor.Neutral.grey100
                   .ignoresSafeArea(.all)

               YKNavigationBar(
                   title: "프로필",
                   hasBackButton: true,
                   onBackTapped: {
                       viewStore.send(.backButtonTapped)
                   }
               ) {
                   VStack(spacing: 0) {
                       ProfileImageSection(store: store)
                           .padding(.top, Layout.profileSectionTopPadding)
                           .padding(.bottom, Layout.profileSectionBottomPadding)

                       NicknameInputSection(
                           store: store,
                           localNickname: $localNickname
                       )
                       .padding(.horizontal, Layout.horizontalPadding)

                       Spacer()

                       ChangeButton(store: store)
                           .padding(.horizontal, Layout.horizontalPadding)
                           .padding(.bottom, Layout.changeButtonBottomPadding)
                   }.ignoresSafeArea(.container, edges: .bottom)
               }

               // 로딩 인디케이터
               if viewStore.isLoading {
                   LoadingOverlay()
               }

               // 에러 메시지
               if let error = viewStore.error {
                   ErrorToast(
                       message: error,
                       onDismiss: { viewStore.send(.dismissError) }
                   )
               }
           }
           .onAppear {
               store.send(.onAppear)
           }
           .onChange(of: viewStore.nickname) { oldValue, newValue in
               localNickname = newValue
           }
           .sheet(isPresented: viewStore.binding(
               get: \.showImagePicker,
               send: { _ in .dismissImagePicker }
           )) {
               ImagePicker(onImageSelected: { image in
                   viewStore.send(.imageSelected(image))
               })
           }
           .actionSheet(isPresented: viewStore.binding(
               get: \.showActionSheet,
               send: { _ in .dismissActionSheet }
           )) {
               ActionSheet(
                   title: Text("프로필 사진"),
                   buttons: [
                       .default(Text("사진 선택")) {
                           viewStore.send(.selectFromGallery)
                       },
                       .destructive(Text("기본 이미지로 변경")) {
                           viewStore.send(.removeProfileImage)
                       },
                       .cancel(Text("취소")) {
                           viewStore.send(.dismissActionSheet)
                       }
                   ]
               )
           }
       }
    }
}

private struct ProfileImageSection: View {
    let store: StoreOf<ProfileEditFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.profileImageSpacing) {
                Button(action: {
                    viewStore.send(.profileImageTapped)
                }) {
                    ZStack {
                        // 프로필 이미지
                        Group {
                            if let selectedImage = viewStore.selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if let profileImageURL = viewStore.profileImage {
                                AsyncImage(url: URL(string: profileImageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image("default-profile-small")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                            } else {
                                Image("default-profile-small")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(YKColor.Neutral.grey200, lineWidth: 1)
                        )

                        Circle()
                            .fill(YKColor.Neutral.grey200)
                            .frame(width: Layout.cameraIconBackgroundSize, height: Layout.cameraIconBackgroundSize)
                            .overlay(
                                Image("cached")
                            )
                            .offset(x: 36, y: 36)
                    }
                }
            }
        }
    }
}

private struct NicknameInputSection: View {
    let store: StoreOf<ProfileEditFeature>
    @Binding var localNickname: String

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NicknameTextField(
                text: $localNickname,
                characterCount: viewStore.nicknameCharacterCount,
                onTextChanged: { nickname in
                    viewStore.send(.nicknameChanged(nickname))
                }
            )
        }
    }
}

private struct NicknameTextField: View {
    @Binding var text: String
    let characterCount: String
    let onTextChanged: (String) -> Void

    var body: some View {
        ZStack {
            inputFieldView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(YKColor.Neutral.grey50)
        .cornerRadius(16)
    }

    private var inputFieldView: some View {
        HStack {
            textField
            counterAndClearButton
        }
    }

    private var textField: some View {
        TextField("닉네임을 입력해주세요", text: $text)
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > 5 {
                    text = String(newValue.prefix(5))
                }
                onTextChanged(text)
            }
            .font(YKFont.body1)
            .foregroundColor(YKColor.Neutral.grey950)
    }

    private var counterAndClearButton: some View {
        HStack(spacing: 12) {
            Text(characterCount)
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey400)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onTextChanged("")
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(YKColor.Neutral.grey500)
                }
            }
        }
    }
}

private struct ChangeButton: View {
    let store: StoreOf<ProfileEditFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button(action: {
                viewStore.send(.changeButtonTapped)
            }) {
                Text("변경 완료")
                    .font(YKFont.subtitle2)
                    .foregroundColor(buttonTextColor(isEnabled: viewStore.isChangeButtonEnabled))
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.changeButtonHeight)
            .background(buttonBackgroundColor(isEnabled: viewStore.isChangeButtonEnabled))
            .cornerRadius(Layout.changeButtonCornerRadius)
            .disabled(!viewStore.isChangeButtonEnabled || viewStore.isLoading)
        }
    }

    private func buttonTextColor(isEnabled: Bool) -> Color {
        isEnabled ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400
    }

    private func buttonBackgroundColor(isEnabled: Bool) -> Color {
        isEnabled ? YKColor.Primary.primary400 : YKColor.Neutral.grey200
    }
}

private struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("프로필을 업데이트 중...")
                    .font(YKFont.body2)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
}

private struct ErrorToast: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Text(message)
                    .font(YKFont.body2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(YKColor.Neutral.grey900)
                    )
                    .onTapGesture {
                        onDismiss()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}

private enum Layout {
    static let horizontalPadding: CGFloat = 16
    static let profileSectionTopPadding: CGFloat = 27
    static let profileSectionBottomPadding: CGFloat = 52
    static let profileImageSize: CGFloat = 100
    static let profileImageSpacing: CGFloat = 16
    static let cameraIconBackgroundSize: CGFloat = 32
    static let cameraIconSize: CGFloat = 24
    static let nicknameInputSpacing: CGFloat = 8
    static let changeButtonHeight: CGFloat = 56
    static let changeButtonCornerRadius: CGFloat = 16
    static let changeButtonBottomPadding: CGFloat = 50
}
