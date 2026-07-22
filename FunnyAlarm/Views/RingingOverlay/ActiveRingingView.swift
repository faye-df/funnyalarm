import SwiftUI

/// 响铃主视图 (全屏覆盖，突破静音与专注模式)
public struct ActiveRingingView: View {
    @ObservedObject var viewModel: AlarmRingingViewModel

    public var body: some View {
        ZStack {
            // 背景底色随场景切换
            viewModel.currentScenePack.themeColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header: 场景名称与图标
                VStack(spacing: 6) {
                    HStack {
                        Text("WAKE UP!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(Theme.ink)
                    }

                    HStack(spacing: 6) {
                        Text(viewModel.currentScenePack.icon)
                        Text("今日随机场景：\(viewModel.currentScenePack.name)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Theme.paper)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.ink, lineWidth: 2))
                }
                .padding(.top, 40)

                // 吉祥物震动
                MascotView(state: .shocked)
                    .frame(height: 120)

                // 核心挑战区域
                Group {
                    switch viewModel.currentScenePack.type {
                    case .pose:
                        PoseChallengeView(analyzer: viewModel.visionAnalyzer) {
                            viewModel.fallbackController.triggerFallback(reason: .userRequested)
                        }
                    case .voice:
                        VoiceChallengeView(
                            speechService: viewModel.speechService,
                            promptDetail: viewModel.currentScenePack.promptDetail
                        ) {
                            viewModel.fallbackController.triggerFallback(reason: .userRequested)
                        }
                    case .miniGame:
                        MiniGameChallengeView {
                            viewModel.completeChallenge()
                        }
                    }
                }
                .transition(.opacity)

                Spacer()

                // 底部安全按钮区 (10s 降音量 & 8s 安全强关)
                VStack(spacing: 12) {
                    // 10s 临时降音量按钮
                    Button(action: {
                        viewModel.soundEngine.trigger10sVolumeDip()
                    }) {
                        HStack {
                            Text("🔊")
                            Text(viewModel.soundEngine.isVolumeDipped ? "已降低音量 (\(viewModel.soundEngine.dipRemainingSeconds)s)" : "安全降音 10 秒")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Theme.yellow)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.ink, lineWidth: 2))
                    }

                    // 8s 长按安全强关机制
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.paper)
                            .frame(height: 48)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.ink, lineWidth: 2))

                        // 进度的长按槽
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.accent)
                            .frame(width: max(0, UIScreen.main.bounds.width - 64) * CGFloat(viewModel.safetyExitProgress), height: 48)

                        HStack {
                            Spacer()
                            Text(viewModel.safetyExitProgress > 0 ? "保持长按中... (\(Int(viewModel.safetyExitProgress * 100))%)" : "🆘 长按 8 秒紧急安全退出")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.ink)
                            Spacer()
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 32)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in viewModel.startSafetyExitHold() }
                            .onEnded { _ in viewModel.cancelSafetyExitHold() }
                    )
                }
                .padding(.bottom, 30)
            }
        }
    }
}
