//
//  AppleAuthClient.swift
//  Yakssok
//
//  Created by 김사랑 on 7/26/25.
//

import ComposableArchitecture
import AuthenticationServices
import Foundation

struct AppleAuthClient {
    var login: @Sendable () async throws -> AppleLoginResult
    var logout: @Sendable () async throws -> Void
    var isLoggedIn: @Sendable () -> Bool
}

struct AppleLoginResult: Equatable {
    let identityToken: String
}

extension AppleAuthClient: DependencyKey {
    static let liveValue = Self(
        login: {
            return try await AppleSignInManager.shared.signIn()
        },
        logout: {
            return
        },
        isLoggedIn: {
            return TokenManager.shared.isLoggedIn
        }
    )
}

extension DependencyValues {
    var appleAuthClient: AppleAuthClient {
        get { self[AppleAuthClient.self] }
        set { self[AppleAuthClient.self] = newValue }
    }
}

@MainActor
class AppleSignInManager: NSObject, ObservableObject {
    static let shared = AppleSignInManager()

    private var currentContinuation: CheckedContinuation<AppleLoginResult, Error>?

    private override init() {
        super.init()
    }

    func signIn() async throws -> AppleLoginResult {
        return try await withCheckedThrowingContinuation { continuation in
            guard currentContinuation == nil else {
                continuation.resume(throwing: NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "중복 요청"]))
                return
            }

            currentContinuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    private func completeContinuation(with result: Result<AppleLoginResult, Error>) {
        guard let continuation = currentContinuation else { return }
        currentContinuation = nil

        switch result {
        case .success(let loginResult):
            continuation.resume(returning: loginResult)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completeContinuation(with: .failure(NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 인증 정보"])))
            return
        }

        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            completeContinuation(with: .failure(NSError(domain: "AppleLogin", code: -2, userInfo: [NSLocalizedDescriptionKey: "Identity Token을 받을 수 없음"])))
            return
        }

        let result = AppleLoginResult(identityToken: identityToken)
        completeContinuation(with: .success(result))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completeContinuation(with: .failure(error))
    }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Unable to find window")
        }
        return window
    }
}
