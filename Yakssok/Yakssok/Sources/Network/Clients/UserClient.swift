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
}

extension UserClient: DependencyKey {
    static let liveValue = Self(
        loadUsers: {
            do {
                let response: FollowingListResponse = try await APIClient.shared.request(
                    endpoint: .getFollowingList,
                    method: .GET,
                    body: Optional<String>.none
                )

                if response.code != 0 {
                    throw APIError.serverError(response.code)
                }

                return response.body.followingInfoResponses.map { $0.toUser() }
            } catch {

                return []
            }
        },

        loadUserProfile: {
            let response: UserProfileResponse = try await APIClient.shared.request(
                endpoint: .getUserProfile,
                method: .GET,
                body: Optional<String>.none
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response
        }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
