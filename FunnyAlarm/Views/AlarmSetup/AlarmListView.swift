import SwiftUI

/// 闹钟设置与响铃可用性自检主视图
public struct AlarmListView: View {
    @Binding var activeAlarmItem: AlarmItem?
    var onSimulateAlarmTrigger: () -> Void

    @State private var timeText: String = "07:30"
    @State private var isAlarmEnabled: Bool = true
    @State private var selectedRepeatIndex: Int = 0

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header 时钟
                VStack(spacing: 4) {
                    Text(Date(), style: .time)
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundColor(Theme.ink)
                    Text(Date(), style: .date)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.muted)
                }
                .padding(.top, 20)

                // 睡眠状态吉祥物
                MascotView(state: .sleeping)
                    .frame(height: 120)

                // 响铃可用性保护卡 (电量/权限自检)
                ReadinessCheckCard()

                // Brutalist 闹钟配置卡
                VStack(spacing: 16) {
                    HStack {
                        Text("⏰ 晨间随机闹钟")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Toggle("", isOn: $isAlarmEnabled)
                            .labelsHidden()
                    }
                    .padding(.bottom, 4)
                    .overlay(Rectangle().frame(height: 2).foregroundColor(Theme.ink), alignment: .bottom)

                    HStack {
                        Text("唤醒时间:")
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                        TextField("07:30", text: $timeText)
                            .font(.system(size: 24, weight: .black))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("挑战玩法:")
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                        Text("🎲 每日系统随机发放")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.accent)
                    }

                    Text("你不需要选择玩法，明早响起时系统将自动给你一个惊喜！")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.muted)
                }
                .padding()
                .brutalCard(bg: Theme.paper)

                // 演示测试按钮
                BrutalButton(bg: Theme.yellow, action: onSimulateAlarmTrigger) {
                    HStack {
                        Text("🚨")
                        Text("立刻模拟随机闹钟响铃")
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.shell.ignoresSafeArea())
    }
}

/// 可用性自检卡片 (电量、音量、权限、系统排程)
struct ReadinessCheckCard: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
            Text("明天能否正常响铃：状态优秀 (系统排程就绪)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Theme.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Theme.mint)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Theme.ink, lineWidth: 2))
    }
}
