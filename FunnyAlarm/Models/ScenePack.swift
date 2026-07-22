import Foundation
import SwiftUI

/// 晨间随机挑战分类
public enum ChallengeType: String, Codable, CaseIterable {
    case pose = "pose"          // A. 自拍姿势 (摄像头端侧 Vision 识别)
    case voice = "voice"        // B. 语音互动 (麦克风端侧 ASR 识别)
    case miniGame = "miniGame"  // C. 迷你游戏 (离线小游戏，兜底)

    public var title: String {
        switch self {
        case .pose: return "自拍姿势"
        case .voice: return "语音互动"
        case .miniGame: return "迷你游戏"
        }
    }

    public var icon: String {
        switch self {
        case .pose: return "📸"
        case .voice: return "🎤"
        case .miniGame: return "🎮"
        }
    }
}

/// 场景包数据模型
public struct ScenePack: Identifiable, Codable {
    public let id: String
    public let name: String
    public let icon: String
    public let type: ChallengeType
    public let promptTitle: String
    public let promptDetail: String
    public let keywordsOrTarget: [String] // 语音关键字 或 姿势类型标识 或 小游戏类型
    public let defaultRingtoneName: String
    public let themeHex: String

    public var themeColor: Color {
        Color(hex: themeHex)
    }

    public init(
        id: String,
        name: String,
        icon: String,
        type: ChallengeType,
        promptTitle: String,
        promptDetail: String,
        keywordsOrTarget: [String],
        defaultRingtoneName: String,
        themeHex: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.promptTitle = promptTitle
        self.promptDetail = promptDetail
        self.keywordsOrTarget = keywordsOrTarget
        self.defaultRingtoneName = defaultRingtoneName
        self.themeHex = themeHex
    }
}
