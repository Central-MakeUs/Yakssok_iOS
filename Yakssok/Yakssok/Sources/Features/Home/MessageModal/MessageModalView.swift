//
//  MessageModalView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem
import Combine

struct MessageModalView: View {
    let store: StoreOf<MessageModalFeature>
    @State private var keyboardHeight: CGFloat = 0
    @State private var textFieldFrame: CGRect = .zero

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewStore.send(.closeButtonTapped)
                    }

                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        modalContent
                            .background(
                                GeometryReader { modalGeometry in
                                    Color.clear
                                        .preference(key: TextFieldFramePreferenceKey.self,
                                                    value: modalGeometry.frame(in: .global))
                                }
                            )
                            .offset(y: calculateModalOffset(screenHeight: geometry.size.height))
                            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                    }
                }
            }
            .onReceive(keyboardHeightPublisher) { height in
                keyboardHeight = height
                viewStore.send(.keyboardHeightChanged(height))
            }
            .onPreferenceChange(TextFieldFramePreferenceKey.self) { frame in
                textFieldFrame = frame
            }
        }
    }

    private func calculateModalOffset(screenHeight: CGFloat) -> CGFloat {
        guard keyboardHeight > 0 else { return 0 }

        let textFieldBottom = textFieldFrame.maxY
        let keyboardTop = screenHeight - keyboardHeight
        let desiredSpacing: CGFloat = 20
        let currentSpacing = keyboardTop - textFieldBottom
        let requiredOffset = min(0, currentSpacing - desiredSpacing)

        return requiredOffset
    }

    private var modalContent: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 37.44, height: 4)
                    .background(Color(red: 0.86, green: 0.86, blue: 0.86))
                    .cornerRadius(999)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                ModalHeaderView(
                    store: store,
                    targetUser: viewStore.targetUser,
                    messageType: viewStore.messageType
                )
                ModalContentView(store: store, keyboardHeight: keyboardHeight)
                ModalFooterView(store: store)
            }
            .background(
                RoundedRectangle(cornerRadius: Layout.modalCornerRadius)
                    .fill(YKColor.Neutral.grey50)
            )
            .padding(.horizontal, Layout.modalHorizontalPadding)
            .padding(.bottom, Layout.modalBottomPadding)
        }
    }
}

private struct TextFieldFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
    let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { notification -> CGFloat? in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return nil
            }
            return keyboardFrame.height
        }

    let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }

    return willShow
        .merge(with: willHide)
        .removeDuplicates()
        .eraseToAnyPublisher()
}

private struct ModalContentView: View {
    let store: StoreOf<MessageModalFeature>
    let keyboardHeight: CGFloat

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.contentSpacing) {
                PredefinedMessagesView(store: store)
                CustomMessageView(store: store)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: TextFieldFramePreferenceKey.self,
                                            value: geometry.frame(in: .global))
                        }
                    )
            }
            .padding(.horizontal, Layout.contentHorizontalPadding)
            .padding(.vertical, Layout.contentVerticalPadding)
        }
    }
}

private struct CustomMessageView: View {
    let store: StoreOf<MessageModalFeature>
    @State private var localMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let placeholderText = viewStore.messageType == .nagging ? "한 줄 잔소리" : "한 줄 응원"

            textFieldView(viewStore: viewStore, placeholderText: placeholderText)
                .onAppear {
                    localMessage = viewStore.customMessage
                }
        }
    }

    private func textFieldView(viewStore: ViewStoreOf<MessageModalFeature>, placeholderText: String) -> some View {
        ZStack {
            placeholderView(placeholderText: placeholderText)
            inputFieldView(viewStore: viewStore)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(YKColor.Neutral.grey100)
        .cornerRadius(16)
    }

    private func placeholderView(placeholderText: String) -> some View {
        Group {
            if localMessage.isEmpty {
                HStack {
                    Text(placeholderText)
                        .font(YKFont.body2)
                        .foregroundColor(YKColor.Neutral.grey400)
                    Spacer()
                }
            }
        }
    }

    private func inputFieldView(viewStore: ViewStoreOf<MessageModalFeature>) -> some View {
        HStack {
            textField(viewStore: viewStore)
            counterAndClearButton(viewStore: viewStore)
        }
    }

    private func textField(viewStore: ViewStoreOf<MessageModalFeature>) -> some View {
        TextField("", text: $localMessage)
            .focused($isTextFieldFocused)
            .onChange(of: localMessage) { oldValue, newValue in
                let trimmedValue = String(newValue.prefix(15))
                if localMessage != trimmedValue {
                    localMessage = trimmedValue
                }
                viewStore.send(.customMessageChanged(localMessage))
            }
            .onChange(of: viewStore.customMessage) { _, newValue in
                if localMessage != newValue {
                    localMessage = newValue
                }
            }
            .font(YKFont.body1)
            .foregroundColor(YKColor.Neutral.grey950)
            .submitLabel(.done)
            .onSubmit {
                isTextFieldFocused = false
            }
    }

    private func counterAndClearButton(viewStore: ViewStoreOf<MessageModalFeature>) -> some View {
        HStack(spacing: 12) {
            Text("\(localMessage.count)/15")
                .font(YKFont.body1)
                .foregroundColor(YKColor.Neutral.grey300)
            if !localMessage.isEmpty {
                clearButton(viewStore: viewStore)
            }
        }
    }

    private func clearButton(viewStore: ViewStoreOf<MessageModalFeature>) -> some View {
        Button(action: {
            localMessage = ""
            viewStore.send(.customMessageChanged(""))
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(YKColor.Neutral.grey500)
        }
    }
}

// MARK: - Header Views (기존 코드 유지)
private struct ModalHeaderView: View {
    let store: StoreOf<MessageModalFeature>
    let targetUser: String
    let messageType: MessageType

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let titleAttributedText = createAttributedTitle(
                messageType: messageType,
                count: viewStore.medicines.count
            )
            VStack(spacing: Layout.headerSpacing) {
                HStack(alignment: .bottom) {
                    HStack(spacing: 8) {
                        ModalProfileImageView(
                            targetUserId: viewStore.targetUserId,
                            profileImageURL: viewStore.profileImageURL
                        )
                        UserInfoView(
                            targetUser: targetUser,
                            relationship: viewStore.relationship
                        )
                    }
                    Spacer()
                    Text(titleAttributedText)
                        .font(YKFont.subtitle2)
                        .foregroundColor(YKColor.Neutral.grey500)
                        .alignmentGuide(.bottom) { d in d[.bottom] }
                }
                .padding(.horizontal, Layout.headerHorizontalPadding)
                .padding(.top, Layout.headerTopPadding)

                ModalMedicineListView(store: store)
                Rectangle()
                    .fill(YKColor.Neutral.grey200)
                    .frame(height: 1)
                    .padding(.horizontal, Layout.headerHorizontalPadding)
            }
        }
    }

    private func createAttributedTitle(messageType: MessageType, count: Int) -> AttributedString {
        let baseText = messageType == .nagging
        ? "안먹은 약 \(count)개"
        : "오늘 먹은 약 \(count)개"
        var attributedString = AttributedString(baseText)
        if let range = attributedString.range(of: "\(count)개") {
            attributedString[range].font = YKFont.subtitle2
            attributedString[range].foregroundColor = YKColor.Neutral.grey900
        }
        return attributedString
    }
}

private struct ModalProfileImageView: View {
    let targetUserId: Int
    let profileImageURL: String?

    var body: some View {
        Circle()
            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
            .overlay {
                if let profileImageURL = profileImageURL {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(ProfileImageManager.getImageName(for: String(targetUserId)))
                            .resizable()
                            .scaledToFill()
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                    }
                } else {
                    Image(ProfileImageManager.getImageName(for: String(targetUserId)))
                        .resizable()
                        .scaledToFill()
                        .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                        .clipShape(Circle())
                }
            }
    }
}

private struct UserInfoView: View {
    let targetUser: String
    let relationship: String

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.userInfoSpacing) {
            Text(relationship)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey400)

            Text(targetUser)
                .font(YKFont.body2)
                .foregroundColor(YKColor.Neutral.grey600)
        }
    }
}

private struct ModalMedicineListView: View {
    let store: StoreOf<MessageModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.medicines.count > 3 {
                    ScrollView {
                        medicineList(viewStore: viewStore)
                    }
                    .frame(maxHeight: Layout.maxScrollHeight)
                } else {
                    medicineList(viewStore: viewStore)
                }
            }
            .padding(.horizontal, Layout.headerHorizontalPadding)
        }
    }

    private func medicineList(viewStore: ViewStoreOf<MessageModalFeature>) -> some View {
        VStack(spacing: Layout.medicineListSpacing) {
            ForEach(viewStore.medicines) { medicine in
                MedicineRowView(medicine: medicine)
            }
        }
    }
}

private struct MedicineRowView: View {
    let medicine: Medicine

    var body: some View {
        HStack {
            Circle()
                .fill(medicineColorValue)
                .frame(width: Layout.medicineDotSize, height: Layout.medicineDotSize)

            HStack(spacing: Layout.infoSpacing) {
                Text(medicine.name)
                    .font(YKFont.subtitle2)
                    .foregroundColor(YKColor.Neutral.grey950)
                Rectangle()
                    .fill(YKColor.Neutral.grey300)
                    .frame(width: 1, height: 12)
                Text(medicine.time)
                    .font(YKFont.body2)
                    .foregroundColor(YKColor.Neutral.grey400)
            }

            Spacer()
        }
        .padding(.vertical, Layout.medicineRowVerticalPadding)
        .padding(.horizontal, Layout.medicineRowHorizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Layout.medicineRowCornerRadius)
                .fill(YKColor.Neutral.grey50)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(YKColor.Neutral.grey200, lineWidth: 1)
                )
        )
    }

    private var medicineColorValue: Color {
        medicine.color.colorValue
    }
}

// MARK: - Predefined Messages View
private struct PredefinedMessagesView: View {
    let store: StoreOf<MessageModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Layout.messageGridSpacing) {
                HStack(spacing: Layout.messageGridSpacing) {
                    MessageButton(
                        message: viewStore.predefinedMessages[0],
                        isSelected: viewStore.selectedMessage == viewStore.predefinedMessages[0],
                        messageType: viewStore.messageType
                    ) {
                        viewStore.send(.predefinedMessageSelected(viewStore.predefinedMessages[0]))
                    }
                    MessageButton(
                        message: viewStore.predefinedMessages[1],
                        isSelected: viewStore.selectedMessage == viewStore.predefinedMessages[1],
                        messageType: viewStore.messageType
                    ) {
                        viewStore.send(.predefinedMessageSelected(viewStore.predefinedMessages[1]))
                    }
                    Spacer()
                }
                HStack(spacing: Layout.messageGridSpacing) {
                    MessageButton(
                        message: viewStore.predefinedMessages[2],
                        isSelected: viewStore.selectedMessage == viewStore.predefinedMessages[2],
                        messageType: viewStore.messageType
                    ) {
                        viewStore.send(.predefinedMessageSelected(viewStore.predefinedMessages[2]))
                    }
                    MessageButton(
                        message: viewStore.predefinedMessages[3],
                        isSelected: viewStore.selectedMessage == viewStore.predefinedMessages[3],
                        messageType: viewStore.messageType
                    ) {
                        viewStore.send(.predefinedMessageSelected(viewStore.predefinedMessages[3]))
                    }
                    Spacer()
                }
            }
        }
    }
}

private struct MessageButton: View {
    let message: String
    let isSelected: Bool
    let messageType: MessageType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(message)
                .font(YKFont.body2)
                .foregroundColor(isSelected ? selectedTextColor : YKColor.Neutral.grey950)
                .lineLimit(1)
                .padding(.vertical, Layout.messageButtonVerticalPadding)
                .padding(.horizontal, Layout.messageButtonHorizontalPadding)
                .background(
                    RoundedRectangle(cornerRadius: Layout.messageButtonCornerRadius)
                        .fill(isSelected ? selectedBackgroundColor : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.messageButtonCornerRadius)
                                .stroke(isSelected ? selectedBorderColor : YKColor.Neutral.grey200, lineWidth: 1)
                        )
                )
        }
    }

    private var selectedTextColor: Color {
        switch messageType {
        case .nagging:
            return YKColor.Primary.primary400
        case .encouragement:
            return YKColor.Sub.blue
        }
    }

    private var selectedBackgroundColor: Color {
        switch messageType {
        case .nagging:
            return YKColor.Primary.primary50
        case .encouragement:
            return Color(red: 0.95, green: 0.98, blue: 1)
        }
    }

    private var selectedBorderColor: Color {
        switch messageType {
        case .nagging:
            return YKColor.Primary.primary400
        case .encouragement:
            return YKColor.Sub.blue
        }
    }
}

// MARK: - Footer View
private struct ModalFooterView: View {
    let store: StoreOf<MessageModalFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: Layout.footerButtonSpacing) {
                // 닫기 버튼
                Button(action: {
                    viewStore.send(.closeButtonTapped)
                }) {
                    HStack {
                        Spacer()
                        Text("닫기")
                            .font(YKFont.subtitle2)
                            .foregroundColor(YKColor.Neutral.grey400)
                        Spacer()
                    }
                    .padding(.vertical, Layout.footerButtonVerticalPadding)
                }
                .frame(width: 84)
                .background(
                    RoundedRectangle(cornerRadius: Layout.footerButtonCornerRadius)
                        .fill(YKColor.Neutral.grey100)
                )

                // 전송 버튼
                Button(action: {
                    viewStore.send(.sendButtonTapped)
                }) {
                    HStack {
                        Spacer()
                        Text("전송")
                            .font(YKFont.subtitle2)
                            .foregroundStyle(hasSelectedMessage(viewStore) ? YKColor.Neutral.grey50 : YKColor.Neutral.grey400)
                        Spacer()
                    }
                    .padding(.vertical, Layout.footerButtonVerticalPadding)
                }
                .disabled(!hasSelectedMessage(viewStore))
                .background(
                    RoundedRectangle(cornerRadius: Layout.footerButtonCornerRadius)
                        .fill(hasSelectedMessage(viewStore) ?
                              (viewStore.messageType == .nagging ? YKColor.Primary.primary400 : YKColor.Sub.blue) :
                                YKColor.Neutral.grey150)
                )
            }
            .padding(.horizontal, Layout.footerHorizontalPadding)
            .padding(.bottom, Layout.footerBottomPadding)
        }
    }

    private func hasSelectedMessage(_ viewStore: ViewStoreOf<MessageModalFeature>) -> Bool {
        return !viewStore.selectedMessage.isEmpty || !viewStore.customMessage.isEmpty
    }
}

private enum Layout {
    // 모달 전체
    static let modalCornerRadius: CGFloat = 24
    static let modalHorizontalPadding: CGFloat = 12
    static let modalBottomPadding: CGFloat = 50

    // 헤더
    static let headerSpacing: CGFloat = 20
    static let headerHorizontalPadding: CGFloat = 16
    static let headerTopPadding: CGFloat = 20
    static let profileImageSize: CGFloat = 52
    static let userInfoSpacing: CGFloat = 2

    // 복약 리스트
    static let medicineListSpacing: CGFloat = 8
    static let medicineDotSize: CGFloat = 8
    static let medicineRowVerticalPadding: CGFloat = 16
    static let medicineRowHorizontalPadding: CGFloat = 16
    static let medicineRowCornerRadius: CGFloat = 16
    static let maxScrollHeight: CGFloat = 200

    // 컨텐츠
    static let contentSpacing: CGFloat = 20
    static let contentHorizontalPadding: CGFloat = 16
    static let contentVerticalPadding: CGFloat = 20

    // 메시지 버튼
    static let messageGridSpacing: CGFloat = 8
    static let messageButtonVerticalPadding: CGFloat = 12
    static let messageButtonHorizontalPadding: CGFloat = 16
    static let messageButtonCornerRadius: CGFloat = 12
    static let infoSpacing: CGFloat = 8

    // 푸터
    static let footerButtonSpacing: CGFloat = 8
    static let footerButtonVerticalPadding: CGFloat = 16
    static let footerButtonCornerRadius: CGFloat = 12
    static let footerHorizontalPadding: CGFloat = 16
    static let footerTopPadding: CGFloat = 20
    static let footerBottomPadding: CGFloat = 16
}
