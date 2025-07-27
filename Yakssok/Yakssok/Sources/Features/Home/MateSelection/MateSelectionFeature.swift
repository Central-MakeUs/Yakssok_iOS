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
        var currentUser: User?
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
        case updateCurrentUser(User)
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

            case .updateCurrentUser(let user):
                state.currentUser = user

                if let index = state.users.firstIndex(where: { $0.id == user.id }) {
                    state.users[index] = user
                } else {
                    state.users.insert(user, at: 0)
                }

                if state.selectedUserId.isEmpty {
                    state.selectedUserId = user.id
                    return .send(.delegate(.userSelectionChanged(user)))
                }

                return .none

            case .userSelected(let userId):
                state.selectedUserId = userId
                let selectedUser = state.users.first { $0.id == userId }
                return .send(.delegate(.userSelectionChanged(selectedUser)))

            case .addUserButtonTapped:
                return .send(.delegate(.addUserRequested))

            case .usersLoaded(let users):
                state.users = users
                state.isLoading = false

                if let currentUser = state.currentUser {
                    if !state.users.contains(where: { $0.id == currentUser.id }) {
                        state.users.insert(currentUser, at: 0)
                    }

                    if state.selectedUserId.isEmpty {
                        state.selectedUserId = currentUser.id
                        return .send(.delegate(.userSelectionChanged(currentUser)))
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
}
