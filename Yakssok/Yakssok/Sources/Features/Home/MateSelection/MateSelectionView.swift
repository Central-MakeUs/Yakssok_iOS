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
                HStack(spacing: spacing) {
                    ForEach(Array(viewStore.users.enumerated()), id: \.element.id) { index, user in
                        MateProfileView(
                            user: user,
                            isSelected: user.id == viewStore.selectedUserId,
                            profileSize: profileSize,
                            selectedBorderWidth: selectedBorderWidth
                        ) {
                            viewStore.send(.userSelected(userId: user.id))
                        }
                        .padding(.leading, index == 0 ? 16 : 0)
                    }
                    AddMateButton(profileSize: profileSize) {
                        viewStore.send(.addUserButtonTapped)
                    }
                    .padding(.trailing, 16)
                }
                .padding(selectedBorderWidth)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
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
