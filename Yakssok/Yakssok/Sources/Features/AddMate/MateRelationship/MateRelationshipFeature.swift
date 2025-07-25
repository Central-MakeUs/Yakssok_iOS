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

        var isAddButtonEnabled: Bool {
            !relationship.trimmingCharacters(in: .whitespaces).isEmpty
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
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case mateAddingCompleted
        }
    }

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
                return .none
            case .addMateButtonTapped:
                guard state.isAddButtonEnabled else { return .none }
                state.isLoading = true
                return .run { send in
                    // TODO: 실제 API 호출 - 메이트 등록
                    await send(.addMateSuccess)
                }
            case .addMateSuccess:
                state.isLoading = false
                state.showCompletionModal = true
                return .none
            case .addMateFailed(let error):
                state.isLoading = false
                // TODO: 에러 처리
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
            case .delegate:
                return .none
            }
        }
    }
}
