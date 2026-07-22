import SwiftUI
import SwiftData

/// 应用程序主容器
public struct MainContainerView: View {
    @StateObject private var ringingViewModel = AlarmRingingViewModel()
    @State private var activeAlarmItem: AlarmItem? = nil

    public var body: some View {
        ZStack {
            // 主闹钟配置界面
            AlarmListView(activeAlarmItem: $activeAlarmItem) {
                // 模拟响铃触发
                ringingViewModel.triggerAlarm()
            }

            // 全屏响铃互动覆盖层
            if ringingViewModel.isRingingActive {
                ActiveRingingView(viewModel: ringingViewModel)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }

            // 全屏完成反馈页
            if ringingViewModel.isCompleted {
                CompletionView(
                    scenePack: ringingViewModel.currentScenePack,
                    durationSeconds: Date().timeIntervalSince(ringingViewModel.challengeStartTime)
                ) {
                    ringingViewModel.isCompleted = false
                }
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: ringingViewModel.isRingingActive)
        .animation(.easeInOut(duration: 0.3), value: ringingViewModel.isCompleted)
    }
}
