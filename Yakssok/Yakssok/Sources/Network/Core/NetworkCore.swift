//
//  NetworkCore.swift
//  Yakssok
//
//  Created by 김사랑 on 7/26/25.
//

import Foundation

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

    // MARK: - Friend Endpoints
    case getFollowingList

    // MARK: - Medicine Endpoints
    case medicineData
    case medicineDataForDate(Date)
    case createMedication
    case getMedications
    case getMedicationSchedulesToday
    case getMedicationSchedules(Date, Date)
    case takeMedication(Int)

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

        // Friend
        case .getFollowingList:
            return "/api/friends/followings"

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
