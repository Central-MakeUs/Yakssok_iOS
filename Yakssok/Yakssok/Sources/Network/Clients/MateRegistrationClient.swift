//
//  MateRegistrationClient.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import ComposableArchitecture
import Dependencies
import Foundation

struct MateRegistrationClient {
    var getMyInviteCode: @Sendable () async throws -> String
    var getUserByInviteCode: @Sendable (String) async throws -> UserByInviteCodeBody
    var followFriend: @Sendable (String, String) async throws -> Void
}

extension MateRegistrationClient: DependencyKey {
    static let liveValue = Self(
        getMyInviteCode: {
            let response: MyInviteCodeResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getMyInviteCode,
                method: .GET,
                body: Optional<String>.none
            )
            guard response.code == 0 else {
                throw APIError.serverError(response.code)
            }
            return response.body.inviteCode
        },

        getUserByInviteCode: { inviteCode in
            let response: UserByInviteCodeResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .getUserByInviteCode(inviteCode),
                method: .GET,
                body: Optional<String>.none
            )
            guard response.code == 0 else {
                if response.code == 404 {
                    throw APIError.userNotFound
                }
                throw APIError.serverError(response.code)
            }
            return response.body
        },

        followFriend: { inviteCode, relationName in
            let request = FollowFriendRequest(
                inviteCode: inviteCode,
                relationName: relationName
            )
            let response: FollowFriendResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .followFriend,
                method: .POST,
                body: request
            )
            guard response.code == 0 else {
                throw APIError.serverError(response.code)
            }
        }
    )
}

extension DependencyValues {
    var mateRegistrationClient: MateRegistrationClient {
        get { self[MateRegistrationClient.self] }
        set { self[MateRegistrationClient.self] = newValue }
    }
}
