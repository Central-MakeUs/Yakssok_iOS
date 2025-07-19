//
//  MyMatesFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation

struct MyMatesFeature: Reducer {
    struct State: Equatable {
        var followingUsers: [User] = []
        var followerUsers: [User] = []
        var isLoading: Bool = false
        var error: String?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case backButtonTapped
        case addMateButtonTapped
        case followingUserSelected(userId: String)
        case loadMates
        case matesLoaded(following: [User], followers: [User])
        case loadingFailed(String)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToMyPage
            case navigateToAddMate
        }
    }

    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadMates)

            case .backButtonTapped:
                return .send(.delegate(.backToMyPage))

            case .addMateButtonTapped:
                return .send(.delegate(.navigateToAddMate))

            case .followingUserSelected(let userId):
                return .none

            case .loadMates:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    // Mock 데이터 로드
                    let mockFollowing = MyMatesFeature.createMockUsers()
                    let mockFollowers = MyMatesFeature.createMockFollowers()
                    await send(.matesLoaded(following: mockFollowing, followers: mockFollowers))
                }

            case .matesLoaded(let following, let followers):
                state.followingUsers = following
                state.followerUsers = followers
                state.isLoading = false
                return .none

            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // Mock 데이터 생성 함수들을 static으로 변경
    static func createMockUsers() -> [User] {
        return [
            User(
                id: "user1",
                name: "나",
                profileImage: "https://randomuser.me/api/portraits/med/women/1.jpg"
            ),
            User(
                id: "user2",
                name: "나",
                profileImage: "https://randomuser.me/api/portraits/med/men/1.jpg"
            )
        ]
    }

    static func createMockFollowers() -> [User] {
        return [
            User(
                id: "follower1",
                name: "나",
                profileImage: "https://randomuser.me/api/portraits/med/women/2.jpg"
            ),
            User(
                id: "follower2",
                name: "나",
                profileImage: "https://randomuser.me/api/portraits/med/men/2.jpg"
            )
        ]
    }
}
