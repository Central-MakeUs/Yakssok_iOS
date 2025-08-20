//
//  AlarmSelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture
import AVFoundation

struct AlarmSelectionFeature: Reducer {
    struct State: Equatable {
        var selectedAlarmType: AlarmType = .nagging
        var isNextButtonEnabled: Bool = true
        var isPlaying: Bool = false
        var currentlyPlayingAlarm: AlarmType? = nil

        enum AlarmType: String, CaseIterable, Equatable {
            case gentle = "gentle"
            case rhythm = "rhythm"
            case nagging = "nagging"
            case electronic = "electronic"
            case vibration = "vibration"

            var soundFileName: String {
                switch self {
                case .gentle: 
                    return "feelGood"
                case .rhythm: 
                    return "pillShake"
                case .nagging: 
                    return "scold"
                case .electronic: 
                    return "call"
                case .vibration: 
                    return "vibration"
                }
            }

            var displayName: String {
                switch self {
                case .gentle:
                    return "기분 좋아지는 소리"
                case .rhythm:
                    return "약통 흔드는 소리"
                case .nagging:
                    return "잔소리 해주는 소리"
                case .electronic:
                    return "전화온 듯한 소리"
                case .vibration:
                    return "진동 울리는 소리"
                }
            }

            var toAlarmSound: AlarmSound {
                return AlarmSound(
                    id: self.rawValue,
                    name: self.displayName,
                    fileName: self.soundFileName
                )
            }
        }
    }

    @CasePathable
    enum Action: Equatable {
        case alarmTypeSelected(State.AlarmType)
        case playAlarmSound(State.AlarmType)
        case stopAlarmSound
        case nextButtonTapped
        case audioPlayerFinished
    }

    @Dependency(\.audioPlayer) var audioPlayer

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alarmTypeSelected(let alarmType):
                state.selectedAlarmType = alarmType
                return .send(.playAlarmSound(alarmType))
            case .playAlarmSound(let alarmType):
                if state.isPlaying {
                    return .concatenate(
                        .send(.stopAlarmSound),
                        .send(.playAlarmSound(alarmType))
                    )
                }
                state.isPlaying = true
                state.currentlyPlayingAlarm = alarmType
                return .run { send in
                    await audioPlayer.play(alarmType.soundFileName)
                    await send(.audioPlayerFinished)
                }
            case .stopAlarmSound:
                state.isPlaying = false
                state.currentlyPlayingAlarm = nil
                return .run { _ in
                    await audioPlayer.stop()
                }
            case .nextButtonTapped:
                return .none
            case .audioPlayerFinished:
                state.isPlaying = false
                state.currentlyPlayingAlarm = nil
                return .none
            }
        }
    }
}

struct AudioPlayerClient: Equatable {
    var play: @Sendable (String) async -> Void
    var stop: @Sendable () async -> Void

    static func == (lhs: AudioPlayerClient, rhs: AudioPlayerClient) -> Bool {
        return true
    }
}

extension AudioPlayerClient: DependencyKey {
    static let liveValue = AudioPlayerClient(
        play: { @Sendable fileName in
            await AudioPlayerManager.shared.play(fileName)
        },
        stop: { @Sendable in
            await AudioPlayerManager.shared.stop()
        }
    )

    static let testValue = AudioPlayerClient(
        play: { @Sendable _ in },
        stop: { @Sendable in }
    )
}

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

@MainActor
class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func play(_ fileName: String) async {
        await stop()

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "caf") else {
            return
        }

        let player = try? AVAudioPlayer(contentsOf: url)
        self.audioPlayer = player
        player?.play()
    }

    func stop() async {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
