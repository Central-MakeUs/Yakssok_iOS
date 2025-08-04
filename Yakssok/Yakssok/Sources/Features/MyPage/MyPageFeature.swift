//
//  MyPageFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation

struct MyPageFeature: Reducer {
    struct State: Equatable {
        var userProfile: UserProfile?
        var medicineCount: Int = 0
        var mateCount: Int = 0
        var appVersion: String = "1.0"
        var isLoading: Bool = false
        var error: String? = nil
        var myMedicines: MyMedicinesFeature.State?
        var myMates: MyMatesFeature.State?
        var profileEdit: ProfileEditFeature.State?
        var logoutModal: LogoutModalFeature.State?
        var withdrawalModal: WithdrawalModalFeature.State?
        var showPrivacyPolicy: Bool = false
        var showTermsOfUse: Bool = false
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case loadUserProfile
        case userProfileLoaded(UserProfileResponse)
        case userProfileLoadFailed(String)
        case backButtonTapped
        case profileEditTapped
        case myMedicinesTapped
        case myMatesTapped
        case personalInfoPolicyTapped
        case termsOfUseTapped
        case logoutTapped
        case withdrawalTapped
        case myMedicines(MyMedicinesFeature.Action)
        case myMates(MyMatesFeature.Action)
        case profileEdit(ProfileEditFeature.Action)
        case logoutModal(LogoutModalFeature.Action)
        case withdrawalModal(WithdrawalModalFeature.Action)
        case dismissPrivacyPolicy
        case dismissTermsOfUse
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToHome
            case logoutCompleted
            case withdrawalCompleted
        }
    }

    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadUserProfile)

            case .loadUserProfile:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let response = try await userClient.loadUserProfile()
                        await send(.userProfileLoaded(response))
                    } catch {
                        await send(.userProfileLoadFailed(error.localizedDescription))
                    }
                }

            case .userProfileLoaded(let response):
                state.isLoading = false
                state.userProfile = UserProfile(
                    name: response.body.nickname,
                    profileImage: response.body.profileImageUrl,
                    relationship: nil
                )
                state.medicineCount = response.body.medicationCount
                state.mateCount = response.body.followingCount
                return .none

            case .userProfileLoadFailed(let error):
                state.isLoading = false
                state.error = error
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backToHome))

            case .profileEditTapped:
                state.profileEdit = .init()
                return .none

            case .profileEdit(.delegate(.backToMyPage)):
                state.profileEdit = nil
                return .none

            case .profileEdit(.delegate(.profileUpdated)):
                state.profileEdit = nil
                return .send(.loadUserProfile)

            case .myMedicinesTapped:
                state.myMedicines = .init()
                return .none

            case .myMedicines(.delegate(.backToMyPage)):
                state.myMedicines = nil
                return .none

            case .myMatesTapped:
                state.myMates = .init()
                return .none

            case .myMates(.delegate(.backToMyPage)):
                state.myMates = nil
                return .none

            case .myMates:
                return .none

            case .personalInfoPolicyTapped:
                state.showPrivacyPolicy = true
                return .none

            case .termsOfUseTapped:
                state.showTermsOfUse = true
                return .none

            case .dismissPrivacyPolicy:
                state.showPrivacyPolicy = false
                return .none

            case .dismissTermsOfUse:
                state.showTermsOfUse = false
                return .none

            case .logoutTapped:
                state.logoutModal = .init()
                return .none

            case .withdrawalTapped:
                state.withdrawalModal = .init()
                return .none

            case .logoutModal(.delegate(.dismissed)):
                state.logoutModal = nil
                return .none

            case .logoutModal(.delegate(.logoutCompleted)):
                state.logoutModal = nil
                return .send(.delegate(.logoutCompleted))

            case .withdrawalModal(.delegate(.dismissed)):
                state.withdrawalModal = nil
                return .none

            case .withdrawalModal(.delegate(.withdrawalCompleted)):
                state.withdrawalModal = nil
                return .send(.delegate(.withdrawalCompleted))

            case .logoutModal:
                return .none

            case .withdrawalModal:
                return .none

            case .myMedicines:
                return .none

            case .profileEdit:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.myMedicines, action: \.myMedicines) {
            MyMedicinesFeature()
        }
        .ifLet(\.myMates, action: \.myMates) {
            MyMatesFeature()
        }
        .ifLet(\.profileEdit, action: \.profileEdit) {
            ProfileEditFeature()
        }
        .ifLet(\.logoutModal, action: \.logoutModal) {
            LogoutModalFeature()
        }
        .ifLet(\.withdrawalModal, action: \.withdrawalModal) {
            WithdrawalModalFeature()
        }
    }
}
