//
//  UserModels.swift
//  Yakssok
//
//  Created by 김사랑 on 7/27/25.
//

import Foundation

// MARK: - GET /api/users/me Response
struct UserProfileResponse: Codable, Equatable {
    let code: Int
    let message: String
    let body: UserProfileBody
}

struct UserProfileBody: Codable, Equatable {
    let nickname: String
    let profileImageUrl: String?
    let medicationCount: Int
    let followingCount: Int
}

// MARK: - GET /api/friends/followings Response
struct FollowingListResponse: Codable, Equatable {
    let code: Int
    let message: String
    let body: FollowingListBody
}

struct FollowingListBody: Codable, Equatable {
    let followingInfoResponses: [FollowingInfo]
}

struct FollowingInfo: Codable, Equatable {
    let userId: Int
    let relationName: String
    let profileImageUrl: String?
    let nickName: String
}

// MARK: - API Response to UI Model Conversion
extension FollowingInfo {
    func toUser() -> User {
        return User(
            id: String(userId),
            name: relationName,
            profileImage: profileImageUrl
        )
    }
}
