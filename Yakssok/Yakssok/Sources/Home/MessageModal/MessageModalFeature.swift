//
//  MessageModalFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/10/25.
//

import ComposableArchitecture
import Foundation

struct MessageModalFeature: Reducer {
    struct State: Equatable {
        var selectedMessage: String = ""
        var customMessage: String = ""
        var keyboardHeight: CGFloat = 0
        let targetUser: String
        let messageType: MessageType
        let medicineCount: Int
        let relationship: String
        let medicines: [Medicine]
        var isCustomMessageMode: Bool = false
        var shouldScroll: Bool {
            medicines.count > 2
        }

        var predefinedMessages: [String] {
            switch messageType {
            case .nagging:  // 잔소리 보내기
                return [
                    "얼른 먹어요!",
                    "약 놓쳤어요!",
                    "빨리 드세요!",
                    "먹을 때까지 숨참을게요 흡!"
                ]
            case .encouragement:  // 응원 보내기
                return [
                    "정말 대단하군!",
                    "오늘도 건강 챙기기 완료네요!",
                    "야무진 당신",
                    "칭찬 드려요! 짱!"
                ]
            }
        }
    }

    @CasePathable
    enum Action: Equatable {
        case predefinedMessageSelected(String)
        case customMessageChanged(String)
        case keyboardHeightChanged(CGFloat)
        case sendButtonTapped
        case closeButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .predefinedMessageSelected(let message):
                state.selectedMessage = message
                state.customMessage = ""
                return .none
            case .customMessageChanged(let message):
                state.customMessage = message
                if !message.isEmpty {
                    state.selectedMessage = ""
                }
                return .none
            case .keyboardHeightChanged(let height):
                state.keyboardHeight = height
                return .none
            case .sendButtonTapped:
                // TODO: 메시지 전송 로직
                return .none
            case .closeButtonTapped:
                return .none
            }
        }
    }
}

enum MessageType: Equatable {
    case nagging
    case encouragement
}
