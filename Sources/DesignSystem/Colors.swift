import SwiftUI

extension Color {
    // MARK: - Background
    static let surface0 = Color(hex: 0x000000)
    static let surface1 = Color(hex: 0x1C1C1E)
    static let surface2 = Color(hex: 0x2C2C2E)

    // MARK: - Text
    static let textPrimary = Color(hex: 0xFFFFFF)
    static let textSecondary = Color(hex: 0x8E8E93)
    static let textTertiary = Color(hex: 0x48484A)

    // MARK: - Accent
    static let accentPrimary = Color(hex: 0xFF6B35)
    static let accentSecondary = Color(hex: 0x5856D6)
    static let accentSuccess = Color(hex: 0x30D158)
    static let accentWarning = Color(hex: 0xFFD60A)
    static let accentDanger = Color(hex: 0xFF453A)

    // MARK: - Grid
    static let gridOff = Color(hex: 0x2C2C2E)
    static let gridBorder = Color(hex: 0x3A3A3C)

    // MARK: - Hex Initializer
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
