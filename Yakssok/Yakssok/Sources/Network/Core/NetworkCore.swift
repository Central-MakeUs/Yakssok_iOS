//
//  NetworkCore.swift
//  Yakssok
//
//  Created by 김사랑 on 7/26/25.
//

import Foundation
import UIKit

enum APIConfig {
    static let baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            fatalError("API_BASE_URL을 Info.plist에서 찾을 수 없습니다. Config.xcconfig를 확인하세요.")
        }
        return url
    }()
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIEndpoints {
    // MARK: - Auth Endpoints
    case login
    case join
    case logout
    case refreshToken

    // MARK: - User Endpoints
    case getUserProfile
    case updateUserProfile
    case deleteUser

    // MARK: - Image Endpoints
    case uploadUserImage(type: String)
    case updateUserImage(type: String, oldImageUrl: String)
    case deleteUserImage(imageUrl: String)

    // MARK: - Friend Endpoints
    case getFollowingList
    case getFollowerList

    // MARK: - Medicine Endpoints
    case medicineData
    case medicineDataForDate(Date)
    case createMedication
    case getMedications
    case getMedicationSchedulesToday
    case getMedicationSchedules(Date, Date)
    case takeMedication(Int)
    case stopMedication(String)

    // MARK: - Friend Medicine Endpoints
    case getFriendMedicationSchedulesToday(Int)
    case getFriendMedicationSchedules(Int, Date, Date)

    // MARK: - Feedback Endpoint
    case sendFeedback

    // MARK: - Notification Endpoints
    case getNotifications

    // MARK: - Mate Registration Endpoints
    case getMyInviteCode
    case getUserByInviteCode(String)
    case followFriend

    var path: String {
        switch self {
        // Auth
        case .login:
            return "/api/auth/login"
        case .join:
            return "/api/auth/join"
        case .logout:
            return "/api/auth/logout"
        case .refreshToken:
            return "/api/auth/reissue"

        // User
        case .getUserProfile:
            return "/api/users/me"
        case .updateUserProfile:
            return "/api/users/me"
        case .deleteUser:
            return "/api/users"

        // Image
        case .uploadUserImage(let type):
            return "/api/v1/users/image?type=\(type)"
        case .updateUserImage(let type, let oldImageUrl):
            let encodedUrl = oldImageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "/api/v1/users/image?type=\(type)&oldImageUrl=\(encodedUrl)"
        case .deleteUserImage(let imageUrl):
            let encodedUrl = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "/api/v1/users/image?imageUrl=\(encodedUrl)"

        // Friend
        case .getFollowingList:
            return "/api/friends/followings"
        case .getFollowerList:
            return "/api/friends/followers"

        // Medicine
        case .medicineData:
            return "/api/medicine/data"
        case .medicineDataForDate(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "/api/medicine/data/\(formatter.string(from: date))"
        case .createMedication:
            return "/api/medications"
        case .getMedications:
            return "/api/medications"
        case .getMedicationSchedulesToday:
            return "/api/medication-schedules/today"
        case .getMedicationSchedules(let startDate, let endDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "/api/medication-schedules?startDate=\(start)&endDate=\(end)"
        case .takeMedication(let scheduleId):
            return "/api/medication-schedules/\(scheduleId)/take"
        case .stopMedication(let medicationId):
            return "/api/medications/\(medicationId)/end"

        // Friend Medicine
        case .getFriendMedicationSchedulesToday(let friendId):
            return "/api/medication-schedules/friends/\(friendId)/today"
        case .getFriendMedicationSchedules(let friendId, let startDate, let endDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "/api/medication-schedules/friends/\(friendId)?startDate=\(start)&endDate=\(end)"

        // Feedback
        case .sendFeedback:
            return "/api/feedbacks"

        // Notification
        case .getNotifications:
            return "/api/notifications"

        // Mate Registration
        case .getMyInviteCode:
            return "/api/users/invite-code"
        case .getUserByInviteCode(let inviteCode):
            return "/api/users?inviteCode=\(inviteCode)"
        case .followFriend:
            return "/api/friends"
        }
    }

    var url: URL {
        guard let url = URL(string: APIConfig.baseURL + path) else {
            fatalError("Invalid URL: \(APIConfig.baseURL + path)")
        }
        return url
    }
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case serverError(Int)
    case userNotFound // 404 - 존재하지 않는 회원
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .userNotFound:
            return "존재하지 않는 회원입니다."
        case .decodingError:
            return "데이터 파싱 오류가 발생했습니다."
        case .networkError(let error):
            return "네트워크 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private init() {}

    // MARK: - 토큰이 필요한 일반적인 API 요청
    func request<T: Codable, U: Codable>(
        endpoint: APIEndpoints,
        method: HTTPMethod,
        body: T?
    ) async throws -> U {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // 토큰이 필요한 경우 추가
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(jsonString)")
            }
        }

        return try await performRequest(request)
    }

    // MARK: - 자동 토큰 갱신이 포함된 요청
    func requestWithTokenRefresh<T: Codable, U: Codable>(
        endpoint: APIEndpoints,
        method: HTTPMethod,
        body: T?
    ) async throws -> U {
        do {
            return try await request(endpoint: endpoint, method: method, body: body)
        } catch APIError.serverError(401) {
            // 401 에러 시 토큰 갱신 후 재시도
            try await refreshTokenAndRetry()
            return try await request(endpoint: endpoint, method: method, body: body)
        }
    }

    // MARK: - 토큰이 필요 없는 인증 API 요청 (로그인, 회원가입)
    func authRequest<T: Codable, U: Codable>(
        endpoint: APIEndpoints,
        method: HTTPMethod,
        body: T
    ) async throws -> U {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Body: \(jsonString)")
        }

        return try await performRequest(request)
    }

    // MARK: - 이미지 업로드 (multipart/form-data)
    func uploadImage<U: Codable>(
        endpoint: APIEndpoints,
        image: UIImage
    ) async throws -> U {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        guard let accessToken = TokenManager.shared.accessToken else {
            throw APIError.serverError(401)
        }

        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let imageInfo = getImageInfo(for: image)

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageInfo.fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(imageInfo.contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageInfo.data)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        return try await performRequest(request)
    }

    // MARK: - 이미지 수정 (multipart/form-data)
    func updateImage<U: Codable>(
        endpoint: APIEndpoints,
        image: UIImage
    ) async throws -> U {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 60

        guard let accessToken = TokenManager.shared.accessToken else {
            throw APIError.serverError(401)
        }

        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // 이미지 타입과 데이터 결정
        let imageInfo = getImageInfo(for: image)

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // 파일 파트 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageInfo.fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(imageInfo.contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageInfo.data)
        body.append("\r\n".data(using: .utf8)!)

        // 끝 boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        
        return try await performRequest(request)
    }

    // MARK: - 이미지 업로드 (자동 토큰 갱신 포함)
    func uploadImageWithTokenRefresh<U: Codable>(
        endpoint: APIEndpoints,
        image: UIImage
    ) async throws -> U {
        do {
            return try await uploadImage(endpoint: endpoint, image: image)
        } catch APIError.serverError(401) {
            // 401 에러 시 토큰 갱신 후 재시도
            try await refreshTokenAndRetry()
            return try await uploadImage(endpoint: endpoint, image: image)
        }
    }

    func updateImageWithTokenRefresh<U: Codable>(
        endpoint: APIEndpoints,
        image: UIImage
    ) async throws -> U {
        do {
            return try await updateImage(endpoint: endpoint, image: image)
        } catch APIError.serverError(401) {
            // 401 에러 시 토큰 갱신 후 재시도
            try await refreshTokenAndRetry()
            return try await updateImage(endpoint: endpoint, image: image)
        }
    }

    // MARK: - 토큰 갱신 헬퍼
    private func refreshTokenAndRetry() async throws {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            throw APIError.serverError(401)
        }
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: RefreshTokenResponse = try await authRequest(
            endpoint: .refreshToken,
            method: .POST,
            body: request
        )
        TokenManager.shared.accessToken = response.body.accessToken
    }

    // MARK: - 이미지 처리 헬퍼
    private func getImageInfo(for image: UIImage) -> (fileName: String, contentType: String, data: Data) {
        let uuid = UUID().uuidString.prefix(8)

        // 이미지 크기 조정 (최대 1024x1024)
        let resizedImage = resizeImage(image, maxSize: 1024)

        // JPEG로 압축
        let jpegData = resizedImage.jpegData(compressionQuality: 0.6) ?? Data()

        return (
            fileName: "profile_\(uuid).jpg",
            contentType: "image/jpeg",
            data: jpegData
        )
    }

    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)

        // 이미 크기가 작다면 그대로 반환
        if ratio >= 1.0 {
            return image
        }

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()

        return resizedImage
    }

    // MARK: - 네트워크 요청 수행
    private func performRequest<U: Codable>(_ request: URLRequest) async throws -> U {
        print("API 호출: \(request.url?.absoluteString ?? "Unknown URL")")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("HTTP Status Code: \(httpResponse.statusCode)")

            guard 200...299 ~= httpResponse.statusCode else {
                // 404 에러는 존재하지 않는 회원 (회원가입 필요)
                if httpResponse.statusCode == 404 {
                    throw APIError.userNotFound
                }
                throw APIError.serverError(httpResponse.statusCode)
            }

            return try JSONDecoder().decode(U.self, from: data)
        } catch let error as DecodingError {
            print("JSON 디코딩 에러: \(error)")
            throw APIError.decodingError
        } catch let error as APIError {
            throw error
        } catch {
            print("네트워크 에러: \(error)")
            throw APIError.networkError(error)
        }
    }
}
