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
                return .none
            case .addUserButtonTapped:
                return .none
            case .usersLoaded(let users):
                state.users = users
                state.isLoading = false
                if state.selectedUserId.isEmpty, let firstUser = users.first {
                    state.selectedUserId = firstUser.id
                }
                return .none
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
            }
        }
    }
}
