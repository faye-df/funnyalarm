import Foundation
import AVFoundation
import Speech

/// 随机发放引擎服务
public final class RandomEngine {
    public static let shared = RandomEngine()

    private let userDefaults = UserDefaults.standard
    private let recentScenesKey = "FunnyAlarm_RecentSceneIDs"
    private let recentTypesKey = "FunnyAlarm_RecentChallengeTypes"

    private init() {}

    /// 核心逻辑：结合设备权限与历史去重，随机发放场景包
    public func drawNextScenePack() -> ScenePack {
        let allScenes = SceneDatabase.allScenes
        
        // 1. 检查设备能力与权限限制
        let hasCameraPermission = AVCaptureDevice.authorizationStatus(for: .video) == .authorized || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        #if os(iOS)
        let hasMicPermission = AVAudioSession.sharedInstance().recordPermission == .granted || AVAudioSession.sharedInstance().recordPermission == .undetermined
        #else
        let hasMicPermission = true
        #endif

        // 过滤不可用分类
        var eligibleScenes = allScenes.filter { scene in
            switch scene.type {
            case .pose:
                return hasCameraPermission
            case .voice:
                return hasMicPermission
            case .miniGame:
                return true // 小游戏全离线可用
            }
        }

        if eligibleScenes.isEmpty {
            eligibleScenes = allScenes.filter { $0.type == .miniGame }
        }

        // 2. 去重逻辑：排除最近使用的 1 个场景
        let recentSceneIDs = getRecentSceneIDs()
        if let lastSceneID = recentSceneIDs.last {
            let nonDuplicateScenes = eligibleScenes.filter { $0.id != lastSceneID }
            if !nonDuplicateScenes.isEmpty {
                eligibleScenes = nonDuplicateScenes
            }
        }

        // 3. 类别平衡权重抽样 (保持姿态/语音/小游戏均衡出场)
        let recentTypes = getRecentChallengeTypes()
        let selectedPack: ScenePack

        // 如果连续两天的类型相同，优先选择不同类型
        if recentTypes.count >= 2 && recentTypes[recentTypes.count - 1] == recentTypes[recentTypes.count - 2] {
            let repeatedType = recentTypes.last!
            let preferredScenes = eligibleScenes.filter { $0.type != repeatedType }
            if let picked = preferredScenes.randomElement() {
                selectedPack = picked
            } else {
                selectedPack = eligibleScenes.randomElement()!
            }
        } else {
            selectedPack = eligibleScenes.randomElement()!
        }

        // 4. 更新历史记录
        recordSelectedScene(selectedPack)

        return selectedPack
    }

    // MARK: - 历史记录管理
    private func getRecentSceneIDs() -> [String] {
        userDefaults.stringArray(forKey: recentScenesKey) ?? []
    }

    private func getRecentChallengeTypes() -> [ChallengeType] {
        let rawArray = userDefaults.stringArray(forKey: recentTypesKey) ?? []
        return rawArray.compactMap { ChallengeType(rawValue: $0) }
    }

    private func recordSelectedScene(_ pack: ScenePack) {
        var scenes = getRecentSceneIDs()
        scenes.append(pack.id)
        if scenes.count > 10 { scenes.removeFirst() }
        userDefaults.set(scenes, forKey: recentScenesKey)

        var types = userDefaults.stringArray(forKey: recentTypesKey) ?? []
        types.append(pack.type.rawValue)
        if types.count > 10 { types.removeFirst() }
        userDefaults.set(types, forKey: recentTypesKey)
    }
}
