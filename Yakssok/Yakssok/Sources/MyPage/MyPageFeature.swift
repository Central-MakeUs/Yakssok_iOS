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
        var medicineCount: Int = 3
        var mateCount: Int = 3
        var appVersion: String = "1.1.10"
        var isLoading: Bool = false
        var myMedicines: MyMedicinesFeature.State?
        var myMates: MyMatesFeature.State?
        var profileEdit: ProfileEditFeature.State?
        var showPrivacyPolicy: Bool = false
        var showTermsOfUse: Bool = false
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
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
        case dismissPrivacyPolicy
        case dismissTermsOfUse
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToHome
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.userProfile = UserProfile(
                    name: "1234",
                    profileImage: "https://randomuser.me/api/portraits/med/women/1.jpg",
                    relationship: nil
                )
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
                return .send(.onAppear)

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
                return .none

            case .withdrawalTapped:
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
    }
}
