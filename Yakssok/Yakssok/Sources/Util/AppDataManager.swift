//
//  AppDataManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/8/25.
//

import Foundation

actor AppDataManager {
    static let shared = AppDataManager()

    private var listeners: [String: (DataChangeEvent) async -> Void] = [:]

    private init() {}

    func subscribe(id: String, listener: @escaping (DataChangeEvent) async -> Void) {
        listeners[id] = listener
    }

    func unsubscribe(id: String) {
        listeners.removeValue(forKey: id)
    }

    func notifyDataChanged(_ event: DataChangeEvent) async {
        for (listenerId, listener) in listeners {
            await listener(event)
        }
    }
}

enum DataChangeEvent: Equatable {
    case medicineAdded
    case medicineUpdated
    case medicineDeleted
    case mateAdded
    case mateRemoved
    case profileUpdated
    case allDataChanged
}
