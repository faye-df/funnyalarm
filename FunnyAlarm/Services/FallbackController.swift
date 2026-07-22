import Foundation
import Combine

/// 降级原因枚举
public enum FallbackReason: String {
    case permissionDenied = "权限拒绝"
    case hardwareUnavailable = "硬件缺失"
    case recognitionTimeout = "识别超时"
    case lowLight = "环境光线不足"
    case userRequested = "环境限制请求"
}

/// 2 秒故障自动退路控制器
public final class FallbackController: ObservableObject {
    @Published public var isFallbackActive: Bool = false
    @Published public var currentFallbackReason: FallbackReason? = nil
    @Published public var fallbackMiniGamePack: ScenePack? = nil

    public init() {}

    /// 触发 2 秒退路机制，自动无缝切换至可用迷你游戏
    public func triggerFallback(reason: FallbackReason) {
        guard !isFallbackActive else { return }

        self.currentFallbackReason = reason
        self.isFallbackActive = true

        // 随机选择一个迷你游戏作为兜底
        let miniGamePack = SceneDatabase.allScenes
            .filter { $0.type == .miniGame }
            .randomElement() ?? SceneDatabase.allScenes[12]

        self.fallbackMiniGamePack = miniGamePack
        print("🚨 触发 2 秒自动降级兜底方案: \(reason.rawValue) -> 切换至迷你游戏: \(miniGamePack.name)")
    }

    /// 重置降级状态
    public func reset() {
        self.isFallbackActive = false
        self.currentFallbackReason = nil
        self.fallbackMiniGamePack = nil
    }
}
