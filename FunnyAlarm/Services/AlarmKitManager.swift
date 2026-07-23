import Foundation
import UserNotifications

/// 闹钟服务调度器 (支持 iOS 17+ UNUserNotificationCenter 本地闹钟排程与未来 AlarmKit 扩展)
public final class AlarmKitManager {
    public static let shared = AlarmKitManager()

    private init() {}

    /// 请求闹钟与本地通知权限
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
            return granted
        } catch {
            print("UNUserNotificationCenter auth error: \(error)")
            return false
        }
    }

    /// 调度闹钟排程
    public func scheduleAlarm(_ item: AlarmItem) async throws {
        guard item.isEnabled else {
            try await cancelAlarm(item)
            return
        }

        try await scheduleWithLocalNotifications(item)
    }

    /// 取消闹钟
    public func cancelAlarm(_ item: AlarmItem) async throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }

    // MARK: - Local Notification Alarm Scheduler (iOS 17+)
    private func scheduleWithLocalNotifications(_ item: AlarmItem) async throws {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Funny Alarm 开启"
        content.body = "今天会怎样开始？点击揭晓你的专属晨间开场！"
        content.sound = .defaultCritical

        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: item.time)
        dateComponents.minute = calendar.component(.minute, from: item.time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: !item.repeatDays.isEmpty)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

        try await UNUserNotificationCenter.current().add(request)
    }
}
