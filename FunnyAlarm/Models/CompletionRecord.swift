import Foundation
import SwiftData

/// 挑战完成记录实体 (SwiftData @Model)
@Model
public final class CompletionRecord {
    public var id: UUID
    public var date: Date
    public var sceneId: String
    public var challengeTypeRaw: String
    public var durationSeconds: Double
    public var isFallbackTriggered: Bool
    public var fallbackReason: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        sceneId: String,
        challengeTypeRaw: String,
        durationSeconds: Double,
        isFallbackTriggered: Bool = false,
        fallbackReason: String? = nil
    ) {
        self.id = id
        self.date = date
        self.sceneId = sceneId
        self.challengeTypeRaw = challengeTypeRaw
        self.durationSeconds = durationSeconds
        self.isFallbackTriggered = isFallbackTriggered
        self.fallbackReason = fallbackReason
    }

    public var challengeType: ChallengeType {
        ChallengeType(rawValue: challengeTypeRaw) ?? .miniGame
    }
}
