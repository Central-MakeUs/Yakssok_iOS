//
//  MateRelationshipFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation

struct MateRelationshipFeature: Reducer {
    struct State: Equatable {
        let mateInfo: MateInfo
        var relationship: String = ""
        var isLoading: Bool = false
        var showCompletionModal: Bool = false
        var error: String?

        var isAddButtonEnabled: Bool {
            !relationship.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
        }

        struct MateInfo: Equatable {
            let name: String
            let profileImage: String?
            let code: String
        }
    }

    @CasePathable
    enum Action: Equatable {
        case backButtonTapped
        case relationshipChanged(String)
        case addMateButtonTapped
        case addMateSuccess
        case addMateFailed(String)
        case showCompletionModal
        case dismissCompletionModal
        case confirmButtonTapped
        case dismissError
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case mateAddingCompleted
        }
    }

    @Dependency(\.mateRegistrationClient) var mateRegistrationClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .none

            case .relationshipChanged(let relationship):
                // 한글 기준 5자 제한
                if relationship.count <= 5 {
                    state.relationship = relationship
                }
                state.error = nil
                return .none

            case .addMateButtonTapped:
                guard state.isAddButtonEnabled else { return .none }

                let relationName = state.relationship.trimmingCharacters(in: .whitespaces)
                let inviteCode = state.mateInfo.code

                state.isLoading = true
                state.error = nil

                return .run { send in
                    do {
                        try await mateRegistrationClient.followFriend(inviteCode, relationName)
                        await send(.addMateSuccess)
                    } catch {
                        await send(.addMateFailed("메이트 추가에 실패했어요. 다시 시도해주세요."))
                    }
                }

            case .addMateSuccess:
                state.isLoading = false
                state.showCompletionModal = true
                return .none

            case .addMateFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .showCompletionModal:
                state.showCompletionModal = true
                return .none

            case .dismissCompletionModal:
                state.showCompletionModal = false
                return .none

            case .confirmButtonTapped:
                state.showCompletionModal = false
                return .send(.delegate(.mateAddingCompleted))

            case .dismissError:
                state.error = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
