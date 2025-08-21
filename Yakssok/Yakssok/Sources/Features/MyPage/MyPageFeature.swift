//
//  MyPageFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/19/25.
//

import ComposableArchitecture
import Foundation
import UserNotifications

struct MyPageFeature: Reducer {
    struct State: Equatable {
        var userProfile: UserProfile?
        var medicineCount: Int = 0
        var mateCount: Int = 0
        var appVersion: String = "1.2"
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

        // 알림 권한 관리
        var permissionGranted: Bool = false
        var alertOn: Bool = false

        var isLoadingMyMedicines: Bool = false
        var isLoadingMyMates: Bool = false
        var isLoadingProfileEdit: Bool = false
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case setInitialPermissionState(Bool)
        case appDidBecomeActive
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

        case preloadMyMedicinesData
        case myMedicinesDataLoaded([MedicineRoutine])
        case myMedicinesPreloadFailed(String)
        case preloadMyMatesData
        case myMatesDataLoaded(following: [User], followers: [User])
        case myMatesPreloadFailed(String)
        case preloadProfileEditData
        case profileEditDataLoaded(UserProfileResponse)
        case profileEditPreloadFailed(String)

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

        // 알림 권한 관리
        case checkNotificationPermission
        case notificationPermissionChecked(Bool)
        case notificationToggled(Bool)

        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case backToHome
            case logoutCompleted
            case withdrawalCompleted
        }
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.fcmClient) var fcmClient
    @Dependency(\.medicineClient) var medicineClient

    private let toggleBroadcastID = "toggleBroadcastID"

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
            // 저장된 토글 상태 복원
            let hasToggleSetting = UserDefaults.standard.object(forKey: "userNotificationToggle") != nil
            let savedToggle = UserDefaults.standard.bool(forKey: "userNotificationToggle")
            state.alertOn = hasToggleSetting ? savedToggle : true

            return .merge(
                .send(.startDataSubscription),

                .run { send in
                    let granted = await NotificationPermissionManager.shared.checkPermissionStatus()
                    await send(.setInitialPermissionState(granted))

                    await MainActor.run {
                        NotificationPermissionManager.shared.onPermissionChanged = { callbackGranted in
                            Task { @MainActor in
                                await send(.notificationPermissionChecked(callbackGranted))
                            }
                        }
                        NotificationPermissionManager.shared.onToggleChanged = { newToggleValue in
                            Task { @MainActor in
                                await send(.notificationToggled(newToggleValue))
                            }
                        }
                    }
                },

                .run { send in
                    let center = NotificationCenter.default
                    let name = NotificationPermissionManager.toggleChangedNotification
                    let stream = center.notifications(named: name)

                    for await note in stream {
                        if let enabled = note.userInfo?["enabled"] as? Bool {
                            await send(.notificationToggled(enabled))
                        }
                    }
                }
                .cancellable(id: toggleBroadcastID, cancelInFlight: true)
            )

        case .setInitialPermissionState(let granted):
            state.permissionGranted = granted
            return .none

        case .appDidBecomeActive:
            return .run { send in
                let granted = await NotificationPermissionManager.shared.checkPermissionStatus()
                await send(.notificationPermissionChecked(granted))
            }

        case .checkNotificationPermission:
            return .run { send in
                let granted = await NotificationPermissionManager.shared.checkPermissionStatus()
                await send(.notificationPermissionChecked(granted))
            }

        case .notificationPermissionChecked(let granted):
            let wasGranted = state.permissionGranted
            state.permissionGranted = granted

            if granted != wasGranted {
                if granted {
                    state.alertOn = true
                    UserDefaults.standard.set(true, forKey: "userNotificationToggle")
                    return .run { _ in
                        guard TokenManager.shared.isLoggedIn else { return }
                        try? await fcmClient.sendTokenToServer()
                        await NotificationPermissionManager.shared.handleAppWillEnterForeground()
                    }
                } else {
                    state.alertOn = false
                    UserDefaults.standard.set(false, forKey: "userNotificationToggle")
                    return .run { _ in
                        guard TokenManager.shared.isLoggedIn else { return }
                        await fcmClient.unregister()
                        await NotificationPermissionManager.shared.handleAppWillEnterForeground()
                    }
                }
            }

            return .none

        case .notificationToggled(let newValue):
            guard state.permissionGranted else {
                return .none
            }

            state.alertOn = newValue
            UserDefaults.standard.set(newValue, forKey: "userNotificationToggle")

            return .run { _ in
                guard TokenManager.shared.isLoggedIn else { return }
                if newValue {
                    try? await fcmClient.sendTokenToServer()
                } else {
                    await fcmClient.unregister()
                }

                await NotificationPermissionManager.shared.handleAppWillEnterForeground()
            }

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

        // 내 복용약 프리로딩
        case .myMedicinesTapped:
            guard !state.isLoadingMyMedicines else { return .none }
            state.isLoadingMyMedicines = true
            return .send(.preloadMyMedicinesData)

        case .preloadMyMedicinesData:
            return .run { send in
                do {
                    let medicineData = try await medicineClient.loadMedicineData()
                    await send(.myMedicinesDataLoaded(medicineData.routines))
                } catch {
                    await send(.myMedicinesPreloadFailed(error.localizedDescription))
                }
            }

        case .myMedicinesDataLoaded(let routines):
            state.isLoadingMyMedicines = false

            var myMedicinesState = MyMedicinesFeature.State()
            myMedicinesState.routines = routines

            state.myMedicines = myMedicinesState
            return .none

        case .myMedicinesPreloadFailed(let error):
            state.isLoadingMyMedicines = false
            state.myMedicines = .init()
            return .none

        // 내 메이트 프리로딩
        case .myMatesTapped:
            guard !state.isLoadingMyMates else { return .none }
            state.isLoadingMyMates = true
            return .send(.preloadMyMatesData)

        case .preloadMyMatesData:
            return .run { send in
                do {
                    async let followingTask = userClient.loadFollowingsForMyPage()
                    async let followersTask = userClient.loadFollowers()

                    let following = try await followingTask
                    let followers = try await followersTask

                    await send(.myMatesDataLoaded(following: following, followers: followers))
                } catch {
                    await send(.myMatesPreloadFailed(error.localizedDescription))
                }
            }

        case .myMatesDataLoaded(let following, let followers):
            state.isLoadingMyMates = false

            var myMatesState = MyMatesFeature.State()
            myMatesState.followingUsers = following
            myMatesState.followerUsers = followers

            state.myMates = myMatesState
            return .none

        case .myMatesPreloadFailed(let error):
            state.isLoadingMyMates = false
            state.myMates = .init()
            return .none

        // 프로필 편집 프리로딩
        case .profileEditTapped:
            guard !state.isLoadingProfileEdit else { return .none }
            state.isLoadingProfileEdit = true
            return .send(.preloadProfileEditData)

        case .preloadProfileEditData:
            return .run { send in
                do {
                    let response = try await userClient.loadUserProfile()
                    await send(.profileEditDataLoaded(response))
                } catch {
                    await send(.profileEditPreloadFailed(error.localizedDescription))
                }
            }

        case .profileEditDataLoaded(let response):
            state.isLoadingProfileEdit = false

            var profileEditState = ProfileEditFeature.State()
            profileEditState.nickname = response.body.nickname
            profileEditState.profileImage = response.body.profileImageUrl

            state.profileEdit = profileEditState
            return .run { _ in
                if let imageUrl = response.body.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    await ImageCache.shared.prefetch(url)
                }
            }

        case .profileEditPreloadFailed(let error):
            state.isLoadingProfileEdit = false
            state.profileEdit = .init()
            return .none

        case .profileEdit(.delegate(.backToMyPage)):
            state.profileEdit = nil
            return .none

        case .profileEdit(.delegate(.profileUpdated)):
            state.profileEdit = nil
            return .send(.loadUserProfile)

        case .myMedicines(.delegate(.backToMyPage)):
            state.myMedicines = nil
            return .none

        case .myMedicines(.delegate(.navigateToAddMedicine)):
            return .send(.showAddRoutine)

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
