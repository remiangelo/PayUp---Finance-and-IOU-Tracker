import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Blue liquid wallpaper colors
    let spaceBlack = Color(red: 0, green: 0, blue: 0)
    let brightCyan = Color(red: 0, green: 0.749, blue: 1)
    let electricBlue = Color(red: 0, green: 0.502, blue: 1)
    let darkNavy = Color(red: 0, green: 0.094, blue: 0.251)
    let sparkOrange = Color(red: 1, green: 0.42, blue: 0.208)
    let pureWhite = Color.white

    // Semantic colors for app
    let primaryAccent = Color(red: 0, green: 0.749, blue: 1) // Bright cyan for primary actions
    let secondaryAccent = Color(red: 0, green: 0.502, blue: 1) // Electric blue for secondary
    let background = Color(red: 0, green: 0.031, blue: 0.078) // Very dark blue-black
    let surface = Color(red: 0, green: 0.114, blue: 0.239) // Dark navy for cards
    let onSurface = Color.white // White text on dark surfaces
    let success = Color(red: 0, green: 0.961, blue: 1) // Cyan for positive amounts
    let danger = Color(red: 1, green: 0.42, blue: 0.208) // Orange for negative amounts

    // Glass effects
    let glassBg = Color.white.opacity(0.05)
    let glassStroke = Color(red: 0, green: 0.749, blue: 1).opacity(0.3)
    let shadowColor = Color.black.opacity(0.5)
}