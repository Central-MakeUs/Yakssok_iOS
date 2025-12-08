//
//  MateRegistrationFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation
import UIKit

struct MateRegistrationFeature: Reducer {
    struct State: Equatable {
        var mateCode: String = ""
        var myCode: String = ""
        let currentUserName: String
        var isLoading: Bool = false
        var isLoadingMyCode: Bool = false
        var error: String?
        var showSuccessMessage: Bool = false
        var showShareSheet: Bool = false

        struct AddedMateInfo: Equatable {
            let name: String
            let profileImage: String?
        }

        var addedMateInfo: AddedMateInfo?
        var showCompletionModal: Bool = false

        var isAddButtonEnabled: Bool {
            let trimmedCode = mateCode.trimmingCharacters(in: .whitespaces)
            return trimmedCode.count >= 1 && trimmedCode.count <= 9 && !isLoading
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case backButtonTapped
        case mateCodeChanged(String)
        case addMateButtonTapped
        case copyMyCodeTapped
        case shareInviteTapped
        case dismissShareSheet
        case myCodeLoaded(String)
        case myCodeLoadFailed(String)

        case addMateSuccess(State.AddedMateInfo)
        case addMateFailed(String)

        case dismissSuccessMessage
        case dismissError

        case completionModalConfirmButtonTapped
        case dismissCompletionModal

        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case mateAddingCompleted
        }
    }

    @Dependency(\.mateRegistrationClient) var mateRegistrationClient
    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 앱 시작 시 내 초대 코드 로드
                state.isLoadingMyCode = true
                return .run { send in
                    do {
                        let myInviteCode = try await mateRegistrationClient.getMyInviteCode()
                        await send(.myCodeLoaded(myInviteCode))
                    } catch {
                        await send(.myCodeLoadFailed(error.localizedDescription))
                    }
                }

            case .backButtonTapped:
                NotificationCenter.default.post(
                    name: Notification.Name("yakssok.mate.completed"),
                    object: nil
                )
                return .send(.delegate(.mateAddingCompleted))

            case .mateCodeChanged(let code):
                let filteredCode = code.replacingOccurrences(of: " ", with: "")
                if filteredCode.count <= 9 {
                    state.mateCode = filteredCode
                }
                state.error = nil
                return .none

            case .addMateButtonTapped:
                guard state.isAddButtonEnabled else { return .none }

                let inviteCode = state.mateCode.trimmingCharacters(in: .whitespaces)
                guard !inviteCode.isEmpty else { return .none }

                // 내 코드인지 체크
                if inviteCode == state.myCode {
                    state.error = "자신의 코드는 입력할 수 없어요!"
                    return .none
                }

                state.isLoading = true
                state.error = nil

                return .run { [inviteCode] send in
                    do {
                        let userInfo = try await mateRegistrationClient.getUserByInviteCode(inviteCode)

                        let followingUsers = try await userClient.loadFollowingsForMyPage()
                        let userNames = followingUsers.map { $0.name }
                        let isAlreadyFollowing = userNames.contains(userInfo.nickname)
                        if isAlreadyFollowing {
                            await send(.addMateFailed("이미 등록된 메이트예요!"))
                            return
                        }

                        try await mateRegistrationClient.followFriend(inviteCode, "")
                        await AppDataManager.shared.notifyDataChanged(.mateAdded)

                        let mateInfo = State.AddedMateInfo(
                            name: userInfo.nickname,
                            profileImage: userInfo.profileImageUrl
                        )
                        await send(.addMateSuccess(mateInfo))
                    } catch APIError.userNotFound {
                        await send(.addMateFailed("존재하지 않는 코드예요!"))
                    } catch {
                        await send(.addMateFailed("코드를 다시 확인해주세요!"))
                    }
                }

            case .copyMyCodeTapped:
                // 클립보드에 복사
                UIPasteboard.general.string = state.myCode
                state.showSuccessMessage = true
                return .none

            case .shareInviteTapped:
                state.showShareSheet = true
                return .none

            case .dismissShareSheet:
                state.showShareSheet = false
                return .none

            case .myCodeLoaded(let code):
                state.myCode = code
                state.isLoadingMyCode = false
                return .none

            case .myCodeLoadFailed(let error):
                state.isLoadingMyCode = false
                state.myCode = "로드 실패"
                print("내 초대 코드 로드 실패: \(error)")
                return .none

            case .addMateSuccess(let mateInfo):
                state.isLoading = false
                state.mateCode = ""
                state.addedMateInfo = mateInfo
                state.showCompletionModal = true
                return .none

            case .addMateFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .completionModalConfirmButtonTapped:
                state.showCompletionModal = false
                NotificationCenter.default.post(
                    name: Notification.Name("yakssok.mate.completed"),
                    object: nil
                )
                return .send(.delegate(.mateAddingCompleted))

            case .dismissCompletionModal:
                state.showCompletionModal = false
                return .none

            case .dismissSuccessMessage:
                state.showSuccessMessage = false
                return .none

            case .dismissError:
                state.error = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
