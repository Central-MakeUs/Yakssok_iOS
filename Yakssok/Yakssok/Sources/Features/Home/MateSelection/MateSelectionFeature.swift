//
//  MateSelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/7/25.
//

import ComposableArchitecture

struct MateSelectionFeature: Reducer {
    struct State: Equatable {
        var users: [User] = []
        var selectedUserId: String = ""
        var isLoading: Bool = false
        var error: String?

        var selectedUser: User? {
            users.first { $0.id == selectedUserId }
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case userSelected(userId: String)
        case addUserButtonTapped
        case loadUsers
        case usersLoaded([User])
        case loadingFailed(String)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case userSelectionChanged(User?)
            case addUserRequested
        }
    }

    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadUsers)

            case .loadUsers:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let users = try await userClient.loadUsers()
                        await send(.usersLoaded(users))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .userSelected(let userId):
                state.selectedUserId = userId
                let selectedUser = state.users.first { $0.id == userId }
                return .send(.delegate(.userSelectionChanged(selectedUser)))

            case .addUserButtonTapped:
                return .send(.delegate(.addUserRequested))

            case .usersLoaded(let users):
                state.users = users
                state.isLoading = false

                // 초기 사용자 선택 로직
                if state.selectedUserId.isEmpty {
                    let userToSelect = selectInitialUser(from: users)
                    if let user = userToSelect {
                        state.selectedUserId = user.id
                        return .send(.delegate(.userSelectionChanged(user)))
                    }
                }
                return .none

            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func selectInitialUser(from users: [User]) -> User? {
        // 현재 사용자 자신을 우선 선택
        if let currentUser = users.first(where: { $0.name == "나" || $0.id == "current_user_id" }) {
            return currentUser
        }
        return nil
    }
}
