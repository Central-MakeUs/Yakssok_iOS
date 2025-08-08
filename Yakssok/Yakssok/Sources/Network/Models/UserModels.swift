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

// MARK: - PUT /api/users/me Request
struct UpdateProfileRequest: Codable {
    let nickname: String
    let profileImageUrl: String?
}

// MARK: - PUT /api/users/me Response
struct UpdateProfileResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
}

// MARK: - POST/PUT /api/images Response
struct ImageUploadResponse: Codable {
    let code: Int
    let message: String
    let body: ImageUploadBody
}

struct ImageUploadBody: Codable {
    let imageUrl: String
}

// MARK: - DELETE /api/images Response
struct ImageDeleteResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody
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
            friendId: userId,
            name: relationName,
            profileImage: profileImageUrl
        )
    }
}

extension FollowingInfo {
    func toUserForMyPage() -> User {
        return User(
            id: String(userId),
            friendId: userId,
            name: nickName,
            profileImage: profileImageUrl
        )
    }
}

// MARK: - GET /api/friends/followers Response
struct FollowerListResponse: Codable, Equatable {
    let code: Int
    let message: String
    let body: FollowerListBody
}

struct FollowerListBody: Codable, Equatable {
    let followerInfoResponses: [FollowerInfo]
}

struct FollowerInfo: Codable, Equatable {
    let userId: Int
    let profileImageUrl: String?
    let nickName: String
}

// MARK: - API Response to UI Model Conversion
extension FollowerInfo {
    func toUser() -> User {
        return User(
            id: String(userId),
            friendId: userId,
            name: nickName,
            profileImage: profileImageUrl
        )
    }
}

extension UserProfileResponse {
    func toCurrentUser() -> User {
        return User(
            id: "current_user",
            friendId: nil,
            name: "나",
            profileImage: body.profileImageUrl
        )
    }
}
