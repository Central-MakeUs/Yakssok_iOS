//
//  DeviceIdManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/17/25.
//

import Foundation
import Security
import UIKit

final class DeviceIdManager {
    static let shared = DeviceIdManager()

    private let deviceIdKey = "yakssok_stable_device_id"
    private let service = "VT34K852T5.com.yakssok.app"

    private var cachedDeviceId: String?

    private init() {}

    var stableDeviceId: String {
        if let cached = cachedDeviceId {
            return cached
        }

        if let existingId = getDeviceIdFromKeychain() {
            cachedDeviceId = existingId
            return existingId
        }

        let newId = generateNewDeviceId()
        saveDeviceIdToKeychain(newId)
        cachedDeviceId = newId

        return newId
    }

    func regenerateDeviceId() -> String {
        let newId = generateNewDeviceId()
        saveDeviceIdToKeychain(newId)
        cachedDeviceId = newId

        return newId
    }

    private func generateNewDeviceId() -> String {
        return UUID().uuidString
    }

    private func saveDeviceIdToKeychain(_ deviceId: String) {
        guard let data = deviceId.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: deviceIdKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getDeviceIdFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: deviceIdKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let deviceId = String(data: data, encoding: .utf8) else {
            return nil
        }

        return deviceId
    }

    func clearDeviceId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: deviceIdKey
        ]

        SecItemDelete(query as CFDictionary)
        cachedDeviceId = nil
    }
}
