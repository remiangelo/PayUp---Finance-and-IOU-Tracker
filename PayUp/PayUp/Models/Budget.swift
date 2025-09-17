import Foundation
import SwiftUI

struct Budget: Identifiable, Codable {
    let id: UUID
    let name: String
    let amount: Double
    let categoryId: UUID?
    let period: BudgetPeriod
    let startDate: Date
    let endDate: Date
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        categoryId: UUID? = nil,
        period: BudgetPeriod = .monthly,
        startDate: Date = Date(),
        endDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.categoryId = categoryId
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = Date()
    }

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    func spentAmount(transactions: [EnhancedTransaction]) -> Double {
        transactions
            .filter { transaction in
                if let catId = categoryId {
                    return transaction.categoryId == catId &&
                           transaction.date >= startDate &&
                           transaction.date <= endDate
                } else {
                    return transaction.date >= startDate && transaction.date <= endDate
                }
            }
            .reduce(0) { $0 + $1.amount }
    }

    var spentPercentage: Double {
        guard amount > 0 else { return 0 }
        return min((spentAmount(transactions: []) / amount) * 100, 100)
    }

    var remainingAmount: Double {
        max(amount - spentAmount(transactions: []), 0)
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }

    var dailyBudget: Double {
        guard daysRemaining > 0 else { return 0 }
        return remainingAmount / Double(daysRemaining)
    }
}

enum BudgetPeriod: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .daily: return "calendar.day.timeline.left"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .yearly: return "calendar.circle"
        case .custom: return "calendar.badge.plus"
        }
    }

    func nextPeriodDates(from date: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch self {
        case .daily:
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
            return (tomorrow, tomorrow)
        case .weekly:
            let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: date)!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: nextWeek)!
            return (nextWeek, endOfWeek)
        case .monthly:
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: date)!
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            return (startOfMonth, endOfMonth)
        case .yearly:
            let nextYear = calendar.date(byAdding: .year, value: 1, to: date)!
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: nextYear))!
            let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear)!
            return (startOfYear, endOfYear)
        case .custom:
            return (date, date)
        }
    }
}