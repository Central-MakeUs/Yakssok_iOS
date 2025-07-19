//
//  MateRegistrationFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation

struct MateRegistrationFeature: Reducer {
    struct State: Equatable {
        var mateCode: String = ""
        var myCode: String = "abcdef1gh"
        var isLoading: Bool = false
        var error: String?
        var showSuccessMessage: Bool = false
        var mateRelationship: MateRelationshipFeature.State?

        var isAddButtonEnabled: Bool {
            let trimmedCode = mateCode.trimmingCharacters(in: .whitespaces)
            return trimmedCode.count >= 1 && trimmedCode.count <= 9
        }
    }

    @CasePathable
    enum Action: Equatable {
        case backButtonTapped
        case mateCodeChanged(String)
        case addMateButtonTapped
        case copyMyCodeTapped
        case shareInviteTapped
        case addMateSuccess(MateRelationshipFeature.State.MateInfo)
        case addMateFailed(String)
        case dismissSuccessMessage
        case dismissError
        case mateRelationship(MateRelationshipFeature.Action)
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

            case .mateCodeChanged(let code):
                let filteredCode = code.replacingOccurrences(of: " ", with: "")
                if filteredCode.count <= 9 {
                    state.mateCode = filteredCode
                }
                state.error = nil
                return .none

            case .addMateButtonTapped:
                guard state.isAddButtonEnabled else { return .none }
                state.isLoading = true
                state.error = nil

                return .run { [code = state.mateCode, myCode = state.myCode] send in
                    if code == myCode {
                        await send(.addMateFailed("코드를 다시 확인해주세요!"))
                        return
                    }
                    // Mock: 유효한 코드별 사용자 정보 반환
                    let validUsers: [String: MateRelationshipFeature.State.MateInfo] = [
                        "test12345": MateRelationshipFeature.State.MateInfo(
                            name: "김영희",
                            profileImage: "https://randomuser.me/api/portraits/med/women/75.jpg",
                            code: "test12345"
                        ),
                        "valid123a": MateRelationshipFeature.State.MateInfo(
                            name: "이철수",
                            profileImage: nil,
                            code: "valid123a"
                        ),
                        "friend1gh": MateRelationshipFeature.State.MateInfo(
                            name: "박민수",
                            profileImage: "https://randomuser.me/api/portraits/med/men/11.jpg",
                            code: "friend1gh"
                        )
                    ]
                    if let mateInfo = validUsers[code] {
                        await send(.addMateSuccess(mateInfo))
                    } else {
                        await send(.addMateFailed("코드를 다시 확인해주세요!"))
                    }
                }

            case .copyMyCodeTapped:
                state.showSuccessMessage = true
                return .none

            case .shareInviteTapped:
                return .none

            case .addMateSuccess(let mateInfo):
                state.isLoading = false
                state.mateCode = ""
                state.mateRelationship = MateRelationshipFeature.State(mateInfo: mateInfo)
                return .none

            case .addMateFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .dismissSuccessMessage:
                state.showSuccessMessage = false
                return .none

            case .dismissError:
                state.error = nil
                return .none

            case .mateRelationship(.backButtonTapped):
                state.mateRelationship = nil
                return .none

            case .mateRelationship(.delegate(.mateAddingCompleted)):
                state.mateRelationship = nil
                return .send(.delegate(.mateAddingCompleted))

            case .mateRelationship:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.mateRelationship, action: \.mateRelationship) {
            MateRelationshipFeature()
        }
    }
}
