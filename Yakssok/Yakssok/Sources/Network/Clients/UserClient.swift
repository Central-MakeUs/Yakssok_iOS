//
//  UserClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import ComposableArchitecture

struct UserClient {
    var loadUsers: () async throws -> [User]
    var loadUserProfile: () async throws -> UserProfileResponse
    var loadFollowers: () async throws -> [User]
    var loadFollowingsForMyPage: () async throws -> [User]
    var updateProfile: @Sendable (UpdateProfileRequest) async throws -> Void
}

extension UserClient: DependencyKey {
    static let liveValue = Self(
        loadUsers: {
            let response: FollowingListResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getFollowingList,
                method: .GET,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response.body.followingInfoResponses.map { $0.toUser() }
        },

        loadUserProfile: {
            let response: UserProfileResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getUserProfile,
                method: .GET,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response
        },

        loadFollowers: {
            let response: FollowerListResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getFollowerList,
                method: .GET,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response.body.followerInfoResponses.map { $0.toUser() }
        },

        loadFollowingsForMyPage: {
            let response: FollowingListResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getFollowingList,
                method: .GET,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response.body.followingInfoResponses.map { $0.toUserForMyPage() }
        },

        updateProfile: { request in
            let _: UpdateProfileResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .updateUserProfile,
                method: .PUT,
                body: request
            )
        }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
