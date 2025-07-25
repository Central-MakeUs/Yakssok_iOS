//
//  ProfileEditFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import ComposableArchitecture
import PhotosUI
import UIKit

struct ProfileEditFeature: Reducer {
    struct State: Equatable {
        var nickname: String = ""
        var profileImage: String? = nil
        var isLoading: Bool = false
        var showImagePicker: Bool = false
        var selectedImage: UIImage? = nil
        var showActionSheet: Bool = false
        var error: String? = nil

        var isChangeButtonEnabled: Bool {
            let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)
            return !trimmedNickname.isEmpty && nickname.count <= 5
        }

        var nicknameCharacterCount: String {
            "\(nickname.count)/5"
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case backButtonTapped
        case nicknameChanged(String)
        case profileImageTapped
        case dismissActionSheet
        case selectFromGallery
        case removeProfileImage
        case dismissImagePicker
        case imageSelected(UIImage?)
        case changeButtonTapped
        case profileUpdateSuccess
        case profileUpdateFailed(String)
        case dismissError
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case profileUpdated
            case backToMyPage
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 기존 사용자 정보 로드
                state.nickname = "1234"
                state.profileImage = "https://randomuser.me/api/portraits/med/women/1.jpg"
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backToMyPage))

            case .nicknameChanged(let nickname):
                if nickname.count <= 5 {
                    state.nickname = nickname
                }
                state.error = nil
                return .none

            case .profileImageTapped:
                state.showActionSheet = true
                return .none

            case .dismissActionSheet:
                state.showActionSheet = false
                return .none

            case .selectFromGallery:
                state.showActionSheet = false
                state.showImagePicker = true
                return .none

            case .removeProfileImage:
                state.showActionSheet = false
                state.selectedImage = nil
                state.profileImage = nil
                return .none

            case .dismissImagePicker:
                state.showImagePicker = false
                return .none

            case .imageSelected(let image):
                state.selectedImage = image
                state.showImagePicker = false
                return .none

            case .changeButtonTapped:
                guard state.isChangeButtonEnabled else { return .none }
                state.isLoading = true
                state.error = nil

                return .run { [nickname = state.nickname, image = state.selectedImage] send in
                    // Mock API 호출
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send(.profileUpdateSuccess)
                }

            case .profileUpdateSuccess:
                state.isLoading = false
                return .send(.delegate(.profileUpdated))

            case .profileUpdateFailed(let error):
                state.isLoading = false
                state.error = error
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
