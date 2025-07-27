//
//  User.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

struct User: Equatable {
    let id: String
    let friendId: Int?
    let name: String
    let profileImage: String?

    var isCurrentUser: Bool {
        return name == "나"
    }

    static func defaultCurrentUser() -> User {
        return User(
            id: "current_user",
            friendId: nil,
            name: "나",
            profileImage: nil
        )
    }
}
