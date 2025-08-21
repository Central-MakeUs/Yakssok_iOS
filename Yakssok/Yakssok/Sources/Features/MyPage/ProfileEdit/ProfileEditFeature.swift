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
        var shouldDeleteImage: Bool = false

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
        case profileLoaded(UserProfileResponse)
        case profileApiSuccess
        case profileUpdateFailed(String)
        case dismissError
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case profileUpdated
            case backToMyPage
        }
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.imageClient) var imageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.nickname.isEmpty {
                    return .run { send in
                        do {
                            let response = try await userClient.loadUserProfile()
                            await send(.profileLoaded(response))
                        } catch {
                            // error
                        }
                    }
                }
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
                state.shouldDeleteImage = true
                return .none

            case .dismissImagePicker:
                state.showImagePicker = false
                return .none

            case .imageSelected(let image):
                state.selectedImage = image
                state.shouldDeleteImage = false
                state.showImagePicker = false
                return .none

            case .profileLoaded(let response):
                state.nickname = response.body.nickname
                state.profileImage = response.body.profileImageUrl
                return .none

            case .changeButtonTapped:
                return .run { [nickname = state.nickname, selectedImage = state.selectedImage, currentProfileImage = state.profileImage, shouldDeleteImage = state.shouldDeleteImage] send in
                    do {
                        var newProfileImageUrl: String? = currentProfileImage

                        if shouldDeleteImage {
                            if let oldImageUrl = currentProfileImage {
                                try await imageClient.deleteImage(oldImageUrl)
                            }
                            newProfileImageUrl = nil
                        } else if let image = selectedImage {
                            if currentProfileImage == nil {
                                newProfileImageUrl = try await imageClient.uploadImage(image, "profile")
                            } else {
                                newProfileImageUrl = try await imageClient.updateImage(image, "profile", currentProfileImage!)
                            }
                        }
                        let request = UpdateProfileRequest(
                            nickname: nickname,
                            profileImageUrl: newProfileImageUrl
                        )

                        try await userClient.updateProfile(request)
                        await send(.profileApiSuccess)

                    } catch {
                        await send(.profileUpdateFailed(error.localizedDescription))
                    }
                }

            case .profileApiSuccess:
                state.isLoading = false
                return .run { send in
                    await AppDataManager.shared.notifyDataChanged(.profileUpdated)
                    try await Task.sleep(nanoseconds: 500_000_000)
                    await send(.delegate(.profileUpdated))
                }

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
