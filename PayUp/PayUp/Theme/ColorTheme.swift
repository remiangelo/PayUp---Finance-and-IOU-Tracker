import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Blue liquid wallpaper colors
    let spaceBlack = Color(hex: "000000")
    let brightCyan = Color(hex: "00BFFF")
    let electricBlue = Color(hex: "0080FF")
    let darkNavy = Color(hex: "001840")
    let sparkOrange = Color(hex: "FF6B35")
    let pureWhite = Color.white

    // Semantic colors for app
    let primaryAccent = Color(hex: "00BFFF") // Bright cyan for primary actions
    let secondaryAccent = Color(hex: "0080FF") // Electric blue for secondary
    let background = Color(hex: "000814") // Very dark blue-black
    let surface = Color(hex: "001D3D") // Dark navy for cards
    let onSurface = Color.white // White text on dark surfaces
    let success = Color(hex: "00F5FF") // Cyan for positive amounts
    let danger = Color(hex: "FF6B35") // Orange for negative amounts

    // Glass effects
    let glassBg = Color.white.opacity(0.05)
    let glassStroke = Color(hex: "00BFFF").opacity(0.3)
    let shadowColor = Color.black.opacity(0.5)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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