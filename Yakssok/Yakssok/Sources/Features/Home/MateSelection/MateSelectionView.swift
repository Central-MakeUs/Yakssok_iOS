//
//  MateSelectionView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/7/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct MateSelectionView: View {
    let store: StoreOf<MateSelectionFeature>

    private let profileSize: CGFloat = 52
    private let spacing: CGFloat = 12
    private let selectedBorderWidth: CGFloat = 2

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                createUserProfilesHStack(viewStore: viewStore)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    @ViewBuilder
    private func createUserProfilesHStack(viewStore: ViewStoreOf<MateSelectionFeature>) -> some View {
        HStack(spacing: spacing) {
            createUserProfiles(viewStore: viewStore)
            createAddMateButton(viewStore: viewStore)
        }
        .padding(selectedBorderWidth)
    }

    @ViewBuilder
    private func createUserProfiles(viewStore: ViewStoreOf<MateSelectionFeature>) -> some View {
        ForEach(Array(viewStore.users.enumerated()), id: \.element.id) { index, user in
            createMateProfileView(
                user: user,
                index: index,
                viewStore: viewStore
            )
        }
    }

    @ViewBuilder
    private func createMateProfileView(
        user: User,
        index: Int,
        viewStore: ViewStoreOf<MateSelectionFeature>
    ) -> some View {
        MateProfileView(
            user: user,
            isSelected: user.id == viewStore.selectedUserId,
            profileSize: profileSize,
            selectedBorderWidth: selectedBorderWidth,
            currentUserId: viewStore.currentUser?.id
        ) {
            viewStore.send(.userSelected(userId: user.id))
        }
        .padding(.leading, index == 0 ? 16 : 0)
    }

    @ViewBuilder
    private func createAddMateButton(viewStore: ViewStoreOf<MateSelectionFeature>) -> some View {
        AddMateButton(profileSize: profileSize) {
            viewStore.send(.addUserButtonTapped)
        }
        .padding(.trailing, 16)
    }
}

struct AddMateButton: View {
    let profileSize: CGFloat
    let action: () -> Void

    private let iconPadding: CGFloat = 14
    private let textSpacing: CGFloat = 8

    var body: some View {
        VStack(spacing: textSpacing) {
            Button(action: action) {
                Circle()
                    .fill(YKColor.Neutral.grey100)
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
