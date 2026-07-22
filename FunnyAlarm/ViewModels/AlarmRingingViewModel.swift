import Foundation
import Combine
import SwiftUI

/// 响铃与挑战互动 ViewModel (核心流程状态机)
@MainActor
public final class AlarmRingingViewModel: ObservableObject {
    @Published public var currentScenePack: ScenePack
    @Published public var isRingingActive: Bool = false
    @Published public var isCompleted: Bool = false
    @Published public var challengeStartTime: Date = Date()
    @Published public var elapsedSeconds: Int = 0

    // 8 秒安全退出进度
    @Published public var safetyExitProgress: Double = 0.0
    private var safetyTimer: Timer?

    // 依附的服务
    public let soundEngine = SoundEngine.shared
    public let fallbackController = FallbackController()
    public let visionAnalyzer = VisionPoseAnalyzer()
    public let speechService = SpeechRecognizerService()

    private var cancellables = Set<AnyCancellable>()

    public init(scenePack: ScenePack = SceneDatabase.allScenes[0]) {
        self.currentScenePack = scenePack
        setupSubscriptions()
    }

    /// 触发响铃主流程
    public func triggerAlarm(with pack: ScenePack? = nil) {
        let packToUse = pack ?? RandomEngine.shared.drawNextScenePack()
        self.currentScenePack = packToUse
        self.isRingingActive = true
        self.isCompleted = false
        self.challengeStartTime = Date()
        self.elapsedSeconds = 0

        // 1. 播放响铃
        soundEngine.playRingtone(named: packToUse.defaultRingtoneName)

        // 2. 根据挑战类别初始化监听服务
        startChallengeService(for: packToUse)
    }

    private func startChallengeService(for pack: ScenePack) {
        switch pack.type {
        case .pose:
            visionAnalyzer.startCapture(targetPose: pack.keywordsOrTarget.first ?? "heart")
        case .voice:
            speechService.startListening(targetKeywords: pack.keywordsOrTarget)
        case .miniGame:
            break // 迷你游戏直接交由视图交互
        }
    }

    private func setupSubscriptions() {
        // 订阅 Vision 姿态匹配通过
        visionAnalyzer.$isTargetPoseMatched
            .filter { $0 }
            .sink { [weak self] _ in
                self?.completeChallenge()
            }
            .store(in: &cancellables)

        // 订阅 Speech 语音关键字匹配通过
        speechService.$isMatched
            .filter { $0 }
            .sink { [weak self] _ in
                self?.completeChallenge()
            }
            .store(in: &cancellables)

        // 订阅降级事件
        fallbackController.$isFallbackActive
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self, let fallbackPack = self.fallbackController.fallbackMiniGamePack else { return }
                self.currentScenePack = fallbackPack
                self.visionAnalyzer.stopCapture()
                self.speechService.stopListening()
            }
            .store(in: &cancellables)
    }

    /// 挑战成功完成
    public func completeChallenge() {
        guard !isCompleted else { return }
        self.isCompleted = true
        self.isRingingActive = false

        visionAnalyzer.stopCapture()
        speechService.stopListening()
        soundEngine.stopRingtone()

        let duration = Date().timeIntervalSince(challengeStartTime)
        print("🎉 响铃挑战完成！耗时: \(String(format: "%.1f", duration)) 秒")
    }

    // MARK: - 8 秒安全退出机制
    public func startSafetyExitHold() {
        safetyExitProgress = 0.0
        safetyTimer?.invalidate()
        let startTime = Date()

        safetyTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            Task { @MainActor in
                self.safetyExitProgress = min(1.0, elapsed / 8.0)
                if elapsed >= 8.0 {
                    timer.invalidate()
                    self.completeChallenge() // 安全强关
                }
            }
        }
    }

    public func cancelSafetyExitHold() {
        safetyTimer?.invalidate()
        safetyTimer = nil
        safetyExitProgress = 0.0
    }
}
