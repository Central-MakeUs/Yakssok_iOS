//
//  UserSelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/7/25.
//

import ComposableArchitecture

struct MateSelectionFeature: Reducer {
    struct State: Equatable {
        var users: [User] = []
        var selectedUserId: String = ""

        var selectedUser: User? {
            users.first { $0.id == selectedUserId }
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case userSelected(userId: String)
        case addUserButtonTapped
        case usersLoaded([User])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
#if DEBUG
                // 테스트: 3가지 상태 중 하나 선택해서 테스트: onlyMe, sample, many
                let mockUsers = MockUserData.users(for: .sample)
                return .send(.usersLoaded(mockUsers))
#else
                // TODO: 실제 API 호출 (사용자 목록 조회)
                return .none
#endif
            case .userSelected(let userId):
                state.selectedUserId = userId
                return .none
            case .addUserButtonTapped:
                // TODO: 사용자 추가 화면으로 이동
                return .none
            case .usersLoaded(let users):
                state.users = users
                if state.selectedUserId.isEmpty, let firstUser = users.first {
                    state.selectedUserId = firstUser.id
                }
                return .none
            }
        }
    }
}
