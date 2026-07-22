import Foundation
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

/// 闹钟服务调度器 (支持 iOS 26+ AlarmKit 与 iOS 17+ UNUserNotificationCenter 降级)
public final class AlarmKitManager {
    public static let shared = AlarmKitManager()

    private init() {}

    /// 请求闹钟与通知权限
    public func requestAuthorization() async -> Bool {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            do {
                let state = await AlarmManager.shared.authorizationState
                if state == .notDetermined {
                    return try await AlarmManager.shared.requestAuthorization() == .authorized
                }
                return state == .authorized
            } catch {
                print("AlarmKit authorization failed: \(error)")
            }
        }
        #endif

        // Fallback: UNUserNotificationCenter
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

        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            try await scheduleWithAlarmKit(item)
            return
        }
        #endif

        // Fallback to Local Notifications
        try await scheduleWithLocalNotifications(item)
    }

    /// 取消闹钟
    public func cancelAlarm(_ item: AlarmItem) async throws {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            try await AlarmManager.shared.cancel(id: item.id)
        }
        #endif
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }

    // MARK: - AlarmKit Private Logic (iOS 26+)
    #if canImport(AlarmKit)
    @available(iOS 26.0, *)
    private func scheduleWithAlarmKit(_ item: AlarmItem) async throws {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: item.time)
        let minute = calendar.component(.minute, from: item.time)

        let alert = AlarmPresentation.Alert(
            title: item.label,
            stopButton: AlarmButton(text: "进入晨间开场", textColor: .red, systemImageName: "bell.fill")
        )
        let attributes = AlarmAttributes<CustomAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            tintColor: .orange
        )

        let schedule: Alarm.Schedule
        if item.repeatDays.isEmpty {
            // 单次闹钟
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = hour
            components.minute = minute
            components.second = 0
            
            var targetDate = calendar.date(from: components) ?? item.time
            if targetDate <= Date() {
                targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
            }
            schedule = .fixed(targetDate)
        } else {
            // 每周重复闹钟
            let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
            let daysOfWeek = item.repeatDays.compactMap { dayIndexToDayOfWeek($0) }
            let recurrence = Alarm.Schedule.Relative.Recurrence.weekly(daysOfWeek)
            schedule = .relative(time: time, repeats: recurrence)
        }

        let configuration = AlarmConfiguration(
            schedule: schedule,
            attributes: attributes
        )

        try await AlarmManager.shared.schedule(id: item.id, configuration: configuration)
    }

    @available(iOS 26.0, *)
    private func dayIndexToDayOfWeek(_ index: Int) -> Alarm.Schedule.Relative.Recurrence.DayOfWeek? {
        switch index {
        case 0: return .sunday
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        default: return nil
        }
    }
    #endif

    // MARK: - Local Notification Fallback (iOS 17-25)
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

#if canImport(AlarmKit)
struct CustomAlarmMetadata: AlarmMetadata {
    var alarmLabel: String
}
#endif
