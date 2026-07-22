import SwiftUI

/// Neo-Brutalism 视觉设计系统 Token 字典
public enum Theme {
    // MARK: - 核心色彩 (Core Colors)
    public static let ink = Color(hex: "151515")          // 硬黑主线条
    public static let paper = Color(hex: "FFFDF8")        // 主背景 (米暖白)
    public static let shell = Color(hex: "FFF1F4")        // 浅粉红衬底
    public static let accent = Color(hex: "FF7F6E")       // 主强调色 (珊瑚红)
    public static let accentSoft = Color(hex: "FFD9D2")   // 柔和珊瑚粉
    public static let accentTwo = Color(hex: "6ECDF2")    // 天蓝强调色
    public static let mint = Color(hex: "9FE3C2")         // 薄荷绿 (成功/平静)
    public static let yellow = Color(hex: "FFE46B")       // 警告/醒目黄
    public static let muted = Color(hex: "656565")        // 次要暗灰
    
    // MARK: - 粗野主义尺寸 Token (Brutal Sizing Tokens)
    public static let borderWidth: CGFloat = 4.0          // 4px 标志性硬黑边框
    public static let shadowOffset: CGFloat = 5.0         // 5px 偏移硬阴影
    public static let cornerRadius: CGFloat = 20.0        // 卡片圆角
    public static let buttonCornerRadius: CGFloat = 99.0  // 胶囊按钮极致圆角
}

// MARK: - Color Hex 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Neo-Brutalism ViewModifier 扩展
public struct BrutalCardModifier: ViewModifier {
    var backgroundColor: Color = Theme.paper
    var borderColor: Color = Theme.ink
    var shadowColor: Color = Theme.ink
    var cornerRadius: CGFloat = Theme.cornerRadius

    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: Theme.borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .offset(x: Theme.shadowOffset, y: Theme.shadowOffset)
            )
    }
}

extension View {
    public func brutalCard(
        bg: Color = Theme.paper,
        border: Color = Theme.ink,
        shadow: Color = Theme.ink,
        radius: CGFloat = Theme.cornerRadius
    ) -> some View {
        self.modifier(BrutalCardModifier(backgroundColor: bg, borderColor: border, shadowColor: shadow, cornerRadius: radius))
    }
}
