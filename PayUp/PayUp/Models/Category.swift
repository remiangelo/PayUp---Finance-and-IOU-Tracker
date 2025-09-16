import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    var monthlyBudget: Double?

    init(id: UUID = UUID(), name: String, icon: String, colorHex: String, monthlyBudget: Double? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.monthlyBudget = monthlyBudget
    }

    var color: Color {
        Color(hexString: colorHex)
    }

    static let defaultCategories = [
        Category(name: "Food & Dining", icon: "fork.knife", colorHex: "#FF9500"),
        Category(name: "Transportation", icon: "car.fill", colorHex: "#007AFF"),
        Category(name: "Shopping", icon: "bag.fill", colorHex: "#AF52DE"),
        Category(name: "Entertainment", icon: "tv.fill", colorHex: "#FF2D55"),
        Category(name: "Bills & Utilities", icon: "bolt.fill", colorHex: "#FFCC00"),
        Category(name: "Healthcare", icon: "heart.fill", colorHex: "#FF3B30"),
        Category(name: "Education", icon: "book.fill", colorHex: "#5856D6"),
        Category(name: "Travel", icon: "airplane", colorHex: "#5AC8FA"),
        Category(name: "Personal", icon: "person.fill", colorHex: "#34C759"),
        Category(name: "Other", icon: "ellipsis.circle.fill", colorHex: "#8E8E93")
    ]
}

// MARK: - Color Extension

extension Color {
    init(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let length = hexSanitized.count
        if length == 6 {
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else if length == 8 {
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        } else {
            self.init(.gray)
        }
    }
}