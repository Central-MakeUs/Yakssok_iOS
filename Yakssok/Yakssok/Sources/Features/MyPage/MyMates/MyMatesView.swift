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

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: profileSize), spacing: spacing)
        ]
    }

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
                            VStack(alignment: .leading, spacing: 24) {
                                HStack {
                                    Text("내 메이트 \(viewStore.followerUsers.count)명")
                                        .font(YKFont.body0)
                                        .foregroundColor(YKColor.Neutral.grey800)

                                    Spacer()

                                    Button {
                                        viewStore.send(.addMateButtonTapped)
                                    } label: {
                                        Image("add-pill")
                                            .frame(width: 28, height: 28)
                                    }
                                }
                                .padding(.horizontal, 16)

                                LazyVGrid(
                                    columns: columns,
                                    alignment: .center,
                                    spacing: spacing
                                ) {
                                    ForEach(viewStore.followerUsers, id: \.id) { user in
                                        MateProfileView(
                                            user: user,
                                            isSelected: false,
                                            profileSize: profileSize,
                                            selectedBorderWidth: selectedBorderWidth
                                        ) {}
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                                Spacer(minLength: 0)
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
