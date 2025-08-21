//
//  ProfileImageManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/6/25.
//

import Foundation

enum ProfileImageManager {
    private static let currentUserKey = "current-user-profile-image"

    static func getCurrentUserImageName() -> String {
        return "default-profile-1"
    }

    static func getImageName(for userId: String) -> String {
        let key = "profile-image-\(userId)"

        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }

        let image = "default-profile-\(Int.random(in: 1...3))"
        UserDefaults.standard.set(image, forKey: key)
        return image
    }

    static func getImageName() -> String {
        return getCurrentUserImageName()
    }

    static func resetUserImage(for userId: String) {
        let key = "profile-image-\(userId)"
        let image = "default-profile-\(Int.random(in: 1...3))"
        UserDefaults.standard.set(image, forKey: key)
    }
}

extension ProfileImageManager {
    static func getImageName(for userId: String, isCurrentUser: Bool = false) -> String {
        if isCurrentUser {
            return "default-profile-1"
        }

        return getImageName(for: userId)
    }

    static func getDefaultImageName(for user: User, currentUserId: String?) -> String {
        let isCurrentUser = user.id == currentUserId
        return getImageName(for: user.id, isCurrentUser: isCurrentUser)
    }
}
