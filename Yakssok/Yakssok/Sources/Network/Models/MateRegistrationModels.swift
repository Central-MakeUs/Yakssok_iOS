//
//  MateRegistrationModels.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import Foundation

// MARK: - 내 초대 코드 조회
struct MyInviteCodeResponse: Codable {
    let code: Int
    let message: String
    let body: MyInviteCodeBody
}

struct MyInviteCodeBody: Codable {
    let inviteCode: String
}

// MARK: - 초대 코드로 사용자 조회
struct UserByInviteCodeResponse: Codable {
    let code: Int
    let message: String
    let body: UserByInviteCodeBody
}

struct UserByInviteCodeBody: Codable {
    let nickname: String
    let profileImageUrl: String?
}

// MARK: - 지인 팔로우 (메이트 추가)
struct FollowFriendRequest: Codable {
    let inviteCode: String
    let relationName: String
}

struct FollowFriendResponse: Codable {
    let code: Int
    let message: String
    let body: EmptyBody?
}
