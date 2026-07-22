import Foundation
import SwiftData

/// 闹钟排程数据模型 (SwiftData @Model)
@Model
public final class AlarmItem {
    public var id: UUID
    public var time: Date
    public var isEnabled: Bool
    public var repeatDays: [Int] // 0=Sunday, 1=Monday... 6=Saturday
    public var label: String
    public var isCustomRingtone: Bool
    public var customRingtonePath: String?
    public var volume: Double // 0.0 ~ 1.0
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        time: Date = Date(),
        isEnabled: Bool = true,
        repeatDays: [Int] = [1, 2, 3, 4, 5], // 默认工作日
        label: String = "晨间随机开场",
        isCustomRingtone: Bool = false,
        customRingtonePath: String? = nil,
        volume: Double = 0.8,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.label = label
        self.isCustomRingtone = isCustomRingtone
        self.customRingtonePath = customRingtonePath
        self.volume = volume
        self.createdAt = createdAt
    }

    /// 格式化显示时间 (e.g. 07:30)
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }

    /// 重复日期文本 (e.g. "工作日", "每天", "仅一次")
    public var repeatDaysText: String {
        if repeatDays.isEmpty { return "仅一次" }
        if repeatDays.count == 7 { return "每天" }
        if Set(repeatDays) == Set([1, 2, 3, 4, 5]) { return "工作日" }
        if Set(repeatDays) == Set([0, 6]) { return "周末" }
        
        let dayNames = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return repeatDays.sorted().map { dayNames[$0] }.joined(separator: " ")
    }
}
