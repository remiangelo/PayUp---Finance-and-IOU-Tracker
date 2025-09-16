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

