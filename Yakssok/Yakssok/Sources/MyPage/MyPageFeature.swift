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
                return .none

            case .myMedicinesTapped:
                state.myMedicines = .init()
                return .none

            case .myMedicines(.delegate(.backToMyPage)):
                state.myMedicines = nil
                return .none

            case .myMatesTapped:
                return .none

            case .personalInfoPolicyTapped:
                return .none

            case .termsOfUseTapped:
                return .none

            case .logoutTapped:
                return .none

            case .withdrawalTapped:
                return .none

            case .myMedicines:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.myMedicines, action: \.myMedicines) {
            MyMedicinesFeature()
        }
    }
}
