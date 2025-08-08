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

        case dataChanged(DataChangeEvent)
        case startDataSubscription
        case stopDataSubscription

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
                return .merge(
                    .send(.loadMates),
                    .send(.startDataSubscription)
                )

            case .startDataSubscription:
                return .run { send in
                    await AppDataManager.shared.subscribe(id: "mymates-subscription") { event in
                        await send(.dataChanged(event))
                    }
                }
                .cancellable(id: "mymates-subscription")

            case .stopDataSubscription:
                return .run { _ in
                    await AppDataManager.shared.unsubscribe(id: "mymates-subscription")
                }
                .cancellable(id: "mymates-subscription", cancelInFlight: true)

            case .dataChanged(let event):
                switch event {
                case .mateAdded, .mateRemoved, .allDataChanged:
                    return .send(.loadMates)
                        .debounce(id: "reload-mates", for: 0.3, scheduler: DispatchQueue.main)
                default:
                    return .none
                }

            case .backButtonTapped:
                return .merge(
                    .send(.stopDataSubscription),
                    .send(.delegate(.backToMyPage))
                )

            case .addMateButtonTapped:
                return .send(.delegate(.navigateToAddMate))

            case .followingUserSelected(let userId):
                return .none

            case .loadMates:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let followingUsers = try await userClient.loadFollowingsForMyPage()
                        let followerUsers = try await userClient.loadFollowers()
                        await send(.matesLoaded(following: followingUsers, followers: followerUsers))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
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
}
