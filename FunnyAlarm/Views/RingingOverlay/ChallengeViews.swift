import SwiftUI

/// A. 自拍姿势挑战视图 (前摄实时预览 + Vision 识别进度)
public struct PoseChallengeView: View {
    @ObservedObject var analyzer: VisionPoseAnalyzer
    var onFallbackRequest: () -> Void

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 实时摄像头框 (占位与实时渲染)
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 260)
                    .overlay(
                        VStack {
                            Text("📸 保持姿势并看向前置摄像头")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            Text("系统将在 100% 本地运算完成识别")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.ink, lineWidth: Theme.borderWidth)
                    )

                // 识别进度圈
                if analyzer.matchProgress > 0 {
                    Circle()
                        .stroke(Theme.mint, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .scaleEffect(1.0 + CGFloat(analyzer.matchProgress * 0.2))
                        .overlay(
                            Text("\(Int(analyzer.matchProgress * 100))%")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(Theme.mint)
                        )
                }
            }

            // 环境光线不足或无法姿态检测时的退路选择
            Button(action: onFallbackRequest) {
                Text("⚠️ 环境太暗/无法拍摄？点击切为小游戏")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.muted)
                    .underline()
            }
        }
        .padding()
    }
}

/// B. 语音互动挑战视图 (短句展示 + 端侧关键字反馈)
public struct VoiceChallengeView: View {
    @ObservedObject var speechService: SpeechRecognizerService
    let promptDetail: String
    var onFallbackRequest: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("清理嗓子，大声念出：")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.muted)
                
                Text(promptDetail)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding()
                    .brutalCard(bg: Theme.paper)
            }

            // ASR 实时听写反馈
            VStack(spacing: 4) {
                Text(speechService.isListening ? "🔴 正在聆听中..." : "🎤 点击说话")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.accent)

                if !speechService.transcribedText.isEmpty {
                    Text("听到了: “\(speechService.transcribedText)”")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.yellow)
                        .cornerRadius(8)
                }
            }

            Button(action: onFallbackRequest) {
                Text("⚠️ 环境太吵/不好意思说话？点击切为小游戏")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.muted)
                    .underline()
            }
        }
        .padding()
    }
}

/// C. 4 种迷你游戏挑战视图 (以 4 色按键点阵为例)
public struct MiniGameChallengeView: View {
    var onGameComplete: () -> Void

    @State private var sequence: [Int] = [0, 2, 1, 3]
    @State private var userTapIndex: Int = 0
    @State private var statusText: String = "记住并点击点阵："

    private let gridColors: [Color] = [Theme.accent, Theme.accentTwo, Theme.mint, Theme.yellow]

    public var body: some View {
        VStack(spacing: 16) {
            Text(statusText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.ink)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Button(action: {
                        handleTap(index: index)
                    }) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(gridColors[index])
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Theme.ink, lineWidth: Theme.borderWidth)
                            )
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(Theme.ink)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Text("单手即可在 15-30 秒内快速完成")
                .font(.system(size: 12))
                .foregroundColor(Theme.muted)
        }
        .padding()
        .brutalCard(bg: Theme.paper)
        .padding()
    }

    private func handleTap(index: Int) {
        if index == sequence[userTapIndex] {
            userTapIndex += 1
            if userTapIndex >= sequence.count {
                statusText = "🎉 解锁成功！"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onGameComplete()
                }
            }
        } else {
            userTapIndex = 0
            statusText = "❌ 按错啦，重新按 1-3-2-4 顺序！"
        }
    }
}
