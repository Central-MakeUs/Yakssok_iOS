//
//  DeepLinkManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/19/25.
//

import Foundation

public enum DeepLinkTarget: Equatable {
    case mateInvite(code: String)
    case unknown
}

public final class DeepLinkManager {
    public static let shared = DeepLinkManager()
    public static let notification = Notification.Name("yakssok.deepLink")

    private init() {}

    func handleURL(_ url: URL) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var dict: [String: Any] = [
            "host": url.host ?? "",
            "path": url.path
        ]
        comps?.queryItems?.forEach { dict[$0.name] = $0.value }
        NotificationCenter.default.post(name: Self.notification, object: nil, userInfo: dict)
    }

    public func handleParams(_ params: [String: Any]) {
        NotificationCenter.default.post(name: Self.notification, object: nil, userInfo: params)
    }
}

public extension Dictionary where Key == String, Value == Any {
    var deepLinkTarget: DeepLinkTarget {
        let dlv  = (self["deep_link_value"] as? String) ?? ""
        let code = (self["code"] as? String) ?? ""
        let host = (self["host"] as? String) ?? ""
        let path = (self["path"] as? String) ?? ""

        if dlv == "mate_invite" {
            return .mateInvite(code: code)
        }

        if path.contains("uvut58xg") {
            return .mateInvite(code: code)
        }

        if host == "open" && !code.isEmpty {
            return .mateInvite(code: code)
        }

        if !code.isEmpty {
            return .mateInvite(code: code)
        }

        return .unknown
    }
}

public final class DeepLinkCache {
    public static let shared = DeepLinkCache()
    private var cached: [String: Any]?
    private init() {}

    public func store(_ dict: [String: Any]) { cached = dict }
    public func consume() -> [String: Any]? { defer { cached = nil }; return cached }
}
