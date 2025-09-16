import Foundation
import SwiftUI

struct EnhancedTransaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let description: String
    let categoryId: UUID?
    let date: Date
    let payerId: UUID
    let splitWithUserIds: [UUID]
    let paymentMethod: PaymentMethod
    let currency: Currency
    let notes: String?
    let tags: [String]
    let location: String?
    let receiptId: UUID?
    let isRecurring: Bool
    let recurringInfo: RecurringInfo?
    let groupId: UUID?
    let settlementStatus: SettlementStatus
    let createdAt: Date
    let modifiedAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        description: String,
        categoryId: UUID? = nil,
        date: Date = Date(),
        payerId: UUID,
        splitWithUserIds: [UUID] = [],
        paymentMethod: PaymentMethod = .cash,
        currency: Currency = .usd,
        notes: String? = nil,
        tags: [String] = [],
        location: String? = nil,
        receiptId: UUID? = nil,
        isRecurring: Bool = false,
        recurringInfo: RecurringInfo? = nil,
        groupId: UUID? = nil,
        settlementStatus: SettlementStatus = .pending
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.categoryId = categoryId
        self.date = date
        self.payerId = payerId
        self.splitWithUserIds = splitWithUserIds
        self.paymentMethod = paymentMethod
        self.currency = currency
        self.notes = notes
        self.tags = tags
        self.location = location
        self.receiptId = receiptId
        self.isRecurring = isRecurring
        self.recurringInfo = recurringInfo
        self.groupId = groupId
        self.settlementStatus = settlementStatus
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    var splitAmount: Double {
        guard !splitWithUserIds.isEmpty else { return amount }
        return amount / Double(splitWithUserIds.count + 1) // +1 for the payer
    }

    var formattedAmount: String {
        currency.format(amount)
    }

    var isSettled: Bool {
        settlementStatus == .settled
    }

    var isSplit: Bool {
        !splitWithUserIds.isEmpty
    }
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "Cash"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case bankTransfer = "Bank Transfer"
    case paypal = "PayPal"
    case venmo = "Venmo"
    case applePay = "Apple Pay"
    case googlePay = "Google Pay"
    case zelle = "Zelle"
    case cashApp = "Cash App"
    case cryptocurrency = "Crypto"
    case other = "Other"

    var icon: String {
        switch self {
        case .cash: return "dollarsign.circle.fill"
        case .creditCard, .debitCard: return "creditcard.fill"
        case .bankTransfer: return "building.columns.fill"
        case .paypal: return "p.circle.fill"
        case .venmo: return "v.circle.fill"
        case .applePay: return "applelogo"
        case .googlePay: return "g.circle.fill"
        case .zelle: return "z.circle.fill"
        case .cashApp: return "dollarsign.square.fill"
        case .cryptocurrency: return "bitcoinsign.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Currency

enum Currency: String, Codable, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case chf = "CHF"
    case cny = "CNY"
    case inr = "INR"
    case mxn = "MXN"

    var symbol: String {
        switch self {
        case .usd, .cad, .aud, .mxn: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy, .cny: return "¥"
        case .chf: return "Fr"
        case .inr: return "₹"
        }
    }

    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .chf: return "Swiss Franc"
        case .cny: return "Chinese Yuan"
        case .inr: return "Indian Rupee"
        case .mxn: return "Mexican Peso"
        }
    }

    func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = rawValue
        formatter.currencySymbol = symbol
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbol)\(amount)"
    }
}

// MARK: - Settlement Status

enum SettlementStatus: String, Codable {
    case pending = "Pending"
    case partial = "Partial"
    case settled = "Settled"
    case cancelled = "Cancelled"

    var color: Color {
        switch self {
        case .pending: return .orange
        case .partial: return .yellow
        case .settled: return .green
        case .cancelled: return .red
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .partial: return "circle.lefthalf.filled"
        case .settled: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

// MARK: - Recurring Info

struct RecurringInfo: Codable {
    let frequency: RecurringFrequency
    let endDate: Date?
    let occurrences: Int?

    enum RecurringFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case yearly = "Yearly"

        var days: Int {
            switch self {
            case .daily: return 1
            case .weekly: return 7
            case .biweekly: return 14
            case .monthly: return 30
            case .quarterly: return 90
            case .yearly: return 365
            }
        }
    }
}