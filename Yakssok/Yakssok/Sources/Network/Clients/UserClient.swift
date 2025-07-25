//
//  UserClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/9/25.
//

import ComposableArchitecture

struct UserClient {
    var loadUsers: () async throws -> [User]
}

extension UserClient: DependencyKey {
    static let liveValue = Self(
        loadUsers: {
            // TODO: 실제 API 구현
            // 테스트: 3가지 상태 중 하나 선택해서 테스트: onlyMe, sample, many
            return MockUserData.users(for: .sample)
        }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
