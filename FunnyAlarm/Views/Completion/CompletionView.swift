import SwiftUI

/// 完成页与 9:16 隐私保护分享卡生成
public struct CompletionView: View {
    let scenePack: ScenePack
    let durationSeconds: Double
    var onDismiss: () -> Void

    @State private var showShareSheet: Bool = false

    public var body: some View {
        ZStack {
            Theme.mint.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("🎉 唤醒成功！")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(Theme.ink)

                MascotView(state: .victory)
                    .frame(height: 120)

                VStack(spacing: 12) {
                    HStack {
                        Text(scenePack.icon)
                        Text(scenePack.name)
                            .font(.system(size: 18, weight: .bold))
                    }

                    Text("耗时: \(String(format: "%.1f", durationSeconds)) 秒")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.muted)

                    Text("你已摆脱机械关闹钟，开启元气满满的一天！")
                        .font(.system(size: 13, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding()
                .brutalCard(bg: Theme.paper)
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    // 分享卡生成按钮
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Text("🔗")
                            Text("生成 9:16 晨间开场卡")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Theme.ink)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.yellow)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.ink, lineWidth: Theme.borderWidth))
                    }
                    .padding(.horizontal, 24)

                    // 完成并返回
                    BrutalButton(bg: Theme.ink, action: onDismiss) {
                        Text("🚀 开启新的一天")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareCardView(scenePack: scenePack, durationSeconds: durationSeconds)
        }
    }
}

/// 9:16 隐私保护分享卡 View (默认不展示具体住址/卧室画面)
struct ShareCardView: View {
    let scenePack: ScenePack
    let durationSeconds: Double

    var body: some View {
        VStack(spacing: 20) {
            Text("今日晨间开场卡")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 20)

            VStack(spacing: 16) {
                Text("Funny Alarm")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                Text("“你永远不知道，今天会怎样开始。”")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.muted)

                Divider()

                HStack {
                    Text(scenePack.icon)
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text(scenePack.name)
                            .font(.system(size: 18, weight: .bold))
                        Text(scenePack.type.title)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.muted)
                    }
                }

                MascotView(state: .victory)

                Text("耗时 \(String(format: "%.1f", durationSeconds))s 成功唤醒大脑！")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.ink)
            }
            .padding(24)
            .brutalCard(bg: scenePack.themeColor)
            .aspectRatio(9.0 / 16.0, contentMode: .fit)

            Text("🔒 隐私保护：本卡片仅包含场景名与吉祥物结果，默认隐藏位置与环境")
                .font(.system(size: 11))
                .foregroundColor(Theme.muted)
                .padding(.horizontal, 24)

            Spacer()
        }
        .background(Theme.paper)
    }
}
