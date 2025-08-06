//
//  FeedbackAPIClient.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import ComposableArchitecture
import Dependencies
import Foundation

struct FeedbackAPIClient {
    var sendFeedback: @Sendable (FeedbackRequest) async throws -> Void
}

extension FeedbackAPIClient: DependencyKey {
    static let liveValue = Self(
        sendFeedback: { request in
            let response: FeedbackResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .sendFeedback,
                method: .POST,
                body: request
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }
        }
    )
}

extension DependencyValues {
    var feedbackAPIClient: FeedbackAPIClient {
        get { self[FeedbackAPIClient.self] }
        set { self[FeedbackAPIClient.self] = newValue }
    }
}
