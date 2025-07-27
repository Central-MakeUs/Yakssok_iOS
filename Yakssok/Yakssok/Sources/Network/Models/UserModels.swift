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
