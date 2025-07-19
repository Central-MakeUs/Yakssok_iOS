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
                // Mock 사용자 정보
                state.userProfile = UserProfile(
                    name: "리아",
                    profileImage: "https://randomuser.me/api/portraits/med/women/1.jpg",
                    relationship: nil
                )
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backToHome))

            case .profileEditTapped:
                // TODO: 프로필 편집 화면으로 이동
                return .none

            case .myMedicinesTapped:
                // TODO: 내 복약 화면으로 이동
                return .none

            case .myMatesTapped:
                // TODO: 메이트 화면으로 이동
                return .none

            case .personalInfoPolicyTapped:
                // TODO: 개인정보 정책 화면으로 이동
                return .none

            case .termsOfUseTapped:
                // TODO: 이용약관 화면으로 이동
                return .none

            case .logoutTapped:
                // TODO: 로그아웃 처리
                return .none

            case .withdrawalTapped:
                // TODO: 회원탈퇴 처리
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
