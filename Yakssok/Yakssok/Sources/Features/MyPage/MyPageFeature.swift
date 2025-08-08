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
        var mateRegistration: MateRegistrationFeature.State?
        var addRoutine: AddRoutineFeature.State?
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
        case showMateRegistration
        case showAddRoutine
        case myMedicines(MyMedicinesFeature.Action)
        case myMates(MyMatesFeature.Action)
        case profileEdit(ProfileEditFeature.Action)
        case logoutModal(LogoutModalFeature.Action)
        case withdrawalModal(WithdrawalModalFeature.Action)
        case mateRegistration(MateRegistrationFeature.Action)
        case addRoutine(AddRoutineFeature.Action)
        case dismissPrivacyPolicy
        case dismissTermsOfUse

        case dataChanged(DataChangeEvent)
        case startDataSubscription
        case stopDataSubscription

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
        Reduce(handleAction)
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
            .ifLet(\.mateRegistration, action: \.mateRegistration) {
                MateRegistrationFeature()
            }
            .ifLet(\.addRoutine, action: \.addRoutine) {
                AddRoutineFeature()
            }
    }

    private func handleAction(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .merge(
                .send(.loadUserProfile),
                .send(.startDataSubscription)
            )

        case .startDataSubscription:
            return .run { send in
                await AppDataManager.shared.subscribe(id: "mypage-subscription") { event in
                    await send(.dataChanged(event))
                }
            }
            .cancellable(id: "mypage-subscription")

        case .stopDataSubscription:
            return .run { _ in
                await AppDataManager.shared.unsubscribe(id: "mypage-subscription")
            }
            .cancellable(id: "mypage-subscription", cancelInFlight: true)

        case .dataChanged(let event):
            switch event {
            case .medicineAdded, .medicineUpdated, .medicineDeleted,
                 .mateAdded, .mateRemoved, .profileUpdated, .allDataChanged:
                return .send(.loadUserProfile)
                    .debounce(id: "reload-userprofile", for: 0.3, scheduler: DispatchQueue.main)
            }

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
            return .merge(
                .send(.stopDataSubscription),
                .send(.delegate(.backToHome))
            )

        case .profileEditTapped:
            state.profileEdit = .init()
            return .none

        case .profileEdit(.delegate(.backToMyPage)):
            state.profileEdit = nil
            return .none

        case .profileEdit(.delegate(.profileUpdated)):
            state.profileEdit = nil
            return .none

        case .myMedicinesTapped:
            state.myMedicines = .init()
            return .none

        case .myMedicines(.delegate(.backToMyPage)):
            state.myMedicines = nil
            return .none

        case .myMedicines(.delegate(.navigateToAddMedicine)):
            return .send(.showAddRoutine)

        case .myMatesTapped:
            state.myMates = .init()
            return .none

        case .myMates(.delegate(.navigateToAddMate)):
            return .send(.showMateRegistration)

        case .myMates(.delegate(.backToMyPage)):
            state.myMates = nil
            return .none

        case .myMates:
            return .none

        case .showMateRegistration:
            let userName = state.userProfile?.name ?? ""
            state.mateRegistration = .init(currentUserName: userName)
            return .none

        case .showAddRoutine:
            let userName = state.userProfile?.name ?? ""
            var addRoutineState = AddRoutineFeature.State()
            addRoutineState.categorySelection?.userNickname = userName
            state.addRoutine = addRoutineState
            return .none

        case .mateRegistration(.delegate(.mateAddingCompleted)):
            state.mateRegistration = nil
            return .none

        case .mateRegistration(.backButtonTapped):
            state.mateRegistration = nil
            return .none

        case .mateRegistration:
            return .none

        case .addRoutine(.routineSubmissionSucceeded):
            state.addRoutine = nil
            return .none

        case .addRoutine(.dismissRequested):
            state.addRoutine = nil
            return .none

        case .addRoutine:
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
}
