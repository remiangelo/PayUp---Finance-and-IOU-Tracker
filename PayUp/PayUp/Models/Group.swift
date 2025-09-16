import Foundation
import SwiftUI

struct Group: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: GroupType
    var memberIds: [UUID]
    let adminId: UUID
    let description: String?
    let imageData: Data?
    let createdAt: Date
    var isActive: Bool
    var defaultSplitType: SplitType
    var settlementSchedule: SettlementSchedule?
    var totalSpent: Double
    var lastActivityDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: GroupType = .friends,
        memberIds: [UUID] = [],
        adminId: UUID,
        description: String? = nil,
        imageData: Data? = nil,
        defaultSplitType: SplitType = .equal,
        settlementSchedule: SettlementSchedule? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.memberIds = memberIds
        self.adminId = adminId
        self.description = description
        self.imageData = imageData
        self.createdAt = Date()
        self.isActive = true
        self.defaultSplitType = defaultSplitType
        self.settlementSchedule = settlementSchedule
        self.totalSpent = 0
        self.lastActivityDate = Date()
    }

    mutating func addMember(_ userId: UUID) {
        if !memberIds.contains(userId) {
            memberIds.append(userId)
            lastActivityDate = Date()
        }
    }

    mutating func removeMember(_ userId: UUID) {
        memberIds.removeAll { $0 == userId }
        lastActivityDate = Date()
    }

    func calculateBalances(transactions: [EnhancedTransaction]) -> [UUID: Double] {
        var balances: [UUID: Double] = [:]

        // Initialize all members with zero balance
        for memberId in memberIds {
            balances[memberId] = 0
        }

        // Calculate balances from transactions
        for transaction in transactions.filter({ $0.groupId == id }) {
            // Add amount for payer
            balances[transaction.payerId, default: 0] += transaction.amount

            // Subtract split amount for each participant
            let splitAmount = transaction.splitAmount
            for userId in transaction.splitWithUserIds {
                balances[userId, default: 0] -= splitAmount
            }
            // Also subtract for the payer if they're part of the split
            if !transaction.splitWithUserIds.isEmpty {
                balances[transaction.payerId, default: 0] -= splitAmount
            }
        }

        return balances
    }

    func getOptimizedSettlements(transactions: [EnhancedTransaction]) -> [(from: UUID, to: UUID, amount: Double)] {
        let balances = calculateBalances(transactions: transactions)
        var settlements: [(from: UUID, to: UUID, amount: Double)] = []

        var debtors: [(UUID, Double)] = []
        var creditors: [(UUID, Double)] = []

        for (userId, balance) in balances {
            if balance < -0.01 {
                debtors.append((userId, -balance))
            } else if balance > 0.01 {
                creditors.append((userId, balance))
            }
        }

        debtors.sort { $0.1 > $1.1 }
        creditors.sort { $0.1 > $1.1 }

        var debtorIndex = 0
        var creditorIndex = 0

        while debtorIndex < debtors.count && creditorIndex < creditors.count {
            let debtor = debtors[debtorIndex]
            let creditor = creditors[creditorIndex]

            let amount = min(debtor.1, creditor.1)

            if amount > 0.01 {
                settlements.append((from: debtor.0, to: creditor.0, amount: amount))
            }

            debtors[debtorIndex].1 -= amount
            creditors[creditorIndex].1 -= amount

            if debtors[debtorIndex].1 < 0.01 {
                debtorIndex += 1
            }
            if creditors[creditorIndex].1 < 0.01 {
                creditorIndex += 1
            }
        }

        return settlements
    }
}

// MARK: - Group Type

enum GroupType: String, Codable, CaseIterable {
    case friends = "Friends"
    case family = "Family"
    case roommates = "Roommates"
    case couple = "Couple"
    case trip = "Trip"
    case event = "Event"
    case work = "Work"
    case other = "Other"

    var icon: String {
        switch self {
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .roommates: return "building.fill"
        case .couple: return "heart.fill"
        case .trip: return "airplane"
        case .event: return "calendar.badge.plus"
        case .work: return "briefcase.fill"
        case .other: return "folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .friends: return .blue
        case .family: return .green
        case .roommates: return .orange
        case .couple: return .pink
        case .trip: return .purple
        case .event: return .yellow
        case .work: return .gray
        case .other: return .indigo
        }
    }
}

// MARK: - Split Type

enum SplitType: String, Codable, CaseIterable {
    case equal = "Equal"
    case percentage = "Percentage"
    case shares = "Shares"
    case custom = "Custom"
    case byItem = "By Item"

    var icon: String {
        switch self {
        case .equal: return "equal.circle.fill"
        case .percentage: return "percent"
        case .shares: return "chart.pie.fill"
        case .custom: return "slider.horizontal.3"
        case .byItem: return "list.bullet"
        }
    }

    var description: String {
        switch self {
        case .equal: return "Split equally among all"
        case .percentage: return "Split by percentage"
        case .shares: return "Split by shares"
        case .custom: return "Custom split amounts"
        case .byItem: return "Split individual items"
        }
    }
}

// MARK: - Settlement Schedule

struct SettlementSchedule: Codable {
    let frequency: SettlementFrequency
    let dayOfMonth: Int?
    let dayOfWeek: Int?
    let reminderEnabled: Bool
    let autoSettle: Bool

    enum SettlementFrequency: String, Codable, CaseIterable {
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case manual = "Manual"

        var description: String {
            switch self {
            case .weekly: return "Every week"
            case .biweekly: return "Every two weeks"
            case .monthly: return "Every month"
            case .quarterly: return "Every three months"
            case .manual: return "Settle manually"
            }
        }
    }
}