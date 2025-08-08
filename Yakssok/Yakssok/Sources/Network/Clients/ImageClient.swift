//
//  ImageClient.swift
//  Yakssok
//
//  Created by 김사랑 on 8/5/25.
//

import ComposableArchitecture
import Foundation
import UIKit

struct ImageClient {
    var uploadImage: @Sendable (UIImage, String) async throws -> String
    var updateImage: @Sendable (UIImage, String, String) async throws -> String
    var deleteImage: @Sendable (String) async throws -> Void
}

extension ImageClient: DependencyKey {
    static let liveValue = Self(
        uploadImage: { image, type in
            let response: ImageUploadResponse = try await APIClient.shared.uploadImageWithTokenRefresh(
                endpoint: .uploadUserImage(type: type),
                image: image
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response.body.imageUrl
        },

        updateImage: { image, type, oldImageUrl in
            let response: ImageUploadResponse = try await APIClient.shared.updateImageWithTokenRefresh(
                endpoint: .updateUserImage(type: type, oldImageUrl: oldImageUrl),
                image: image
            )

            if response.code != 0 {
                throw APIError.serverError(response.code)
            }

            return response.body.imageUrl
        },

        deleteImage: { imageUrl in
            let _: ImageDeleteResponse = try await APIClient.shared.requestWithTokenRefresh(
                endpoint: .deleteUserImage(imageUrl: imageUrl),
                method: .DELETE,
                body: Optional<String>.none
            )
        }
    )
}

extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
