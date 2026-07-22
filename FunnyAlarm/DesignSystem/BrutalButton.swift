import SwiftUI

/// Neo-Brutalism 标志性粗边框硬阴影按钮
public struct BrutalButton<Content: View>: View {
    let action: () -> Void
    let backgroundColor: Color
    let content: () -> Content

    @State private var isPressed: Bool = false

    public init(
        bg: Color = Theme.yellow,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backgroundColor = bg
        self.action = action
        self.content = content
    }

    public var body: some View {
        Button(action: {
            action()
        }) {
            content()
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.ink, lineWidth: Theme.borderWidth)
                )
                .background(
                    Capsule()
                        .fill(Theme.ink)
                        .offset(x: isPressed ? 1 : Theme.shadowOffset, y: isPressed ? 1 : Theme.shadowOffset)
                )
                .offset(x: isPressed ? Theme.shadowOffset - 1 : 0, y: isPressed ? Theme.shadowOffset - 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.easeOut(duration: 0.1), value: isPressed)
    }
}

struct BrutalButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BrutalButton(bg: Theme.yellow, action: {}) {
                Text("🔔 模拟闹钟响铃")
            }
            BrutalButton(bg: Theme.accent, action: {}) {
                Text("🎤 拍照/按住说话")
            }
        }
        .padding()
        .background(Theme.shell)
    }
}
