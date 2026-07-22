import SwiftUI

/// 吉祥物情绪状态枚举
public enum MascotState {
    case sleeping   // 睡眠 (Idle)
    case shocked    // 震惊/叫醒 (Ringing)
    case victory    // 胜利/得意 (Success)
    case dark       // 暗黑/恶魔彩蛋模式
}

/// Funny Alarm 原创拟人化状态吉祥物
public struct MascotView: View {
    public var state: MascotState
    
    @State private var isBreathing: Bool = false
    @State private var shakeOffset: CGFloat = 0

    public init(state: MascotState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            // 睡眠模式下的 ZZZ 气泡
            if state == .sleeping {
                ZStack {
                    Text("z")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.accentTwo)
                        .offset(x: 40, y: -45)
                        .opacity(isBreathing ? 0.9 : 0.2)
                        .scaleEffect(isBreathing ? 1.2 : 0.8)
                    Text("Z")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(Theme.accentTwo)
                        .offset(x: 55, y: -65)
                        .opacity(isBreathing ? 0.3 : 0.9)
                        .scaleEffect(isBreathing ? 0.8 : 1.3)
                }
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isBreathing)
            }

            // 精灵主体外形
            ZStack {
                Text(faceExpression)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(state == .dark ? .white : Theme.ink)
            }
            .frame(width: 140, height: 120)
            .background(mascotBgColor)
            .clipShape(OrganicMascotShape())
            .overlay(
                OrganicMascotShape()
                    .stroke(Theme.ink, lineWidth: Theme.borderWidth)
            )
            .background(
                OrganicMascotShape()
                    .fill(Theme.ink)
                    .offset(x: Theme.shadowOffset, y: Theme.shadowOffset)
            )
            .scaleEffect(state == .sleeping && isBreathing ? 1.05 : 1.0)
            .offset(x: state == .shocked ? shakeOffset : 0)
        }
        .onAppear {
            if state == .sleeping {
                isBreathing = true
            } else if state == .shocked {
                withAnimation(.linear(duration: 0.08).repeatForever(autoreverses: true)) {
                    shakeOffset = 4
                }
            }
        }
    }

    private var faceExpression: String {
        switch state {
        case .sleeping: return "- ⩊ -"
        case .shocked: return "O ▱ O"
        case .victory: return "😎"
        case .dark: return "≖_≖"
        }
    }

    private var mascotBgColor: Color {
        switch state {
        case .sleeping: return Theme.accentTwo
        case .shocked: return Theme.yellow
        case .victory: return Theme.mint
        case .dark: return Theme.ink
        }
    }
}

/// 有机变幻的精灵边缘形状
struct OrganicMascotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.2, y: 0))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.3), control: CGPoint(x: w * 0.8, y: -h * 0.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.7, y: h), control: CGPoint(x: w * 1.1, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.7), control: CGPoint(x: w * 0.3, y: h * 1.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.2, y: 0), control: CGPoint(x: -w * 0.1, y: h * 0.2))
        
        return path
    }
}

struct MascotView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            MascotView(state: .sleeping)
            MascotView(state: .shocked)
            MascotView(state: .victory)
        }
        .padding()
        .background(Theme.shell)
    }
}
