import Foundation
import StoreKit

// MARK: - Subscription Types
enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "com.payup.free"
    case premium = "com.payup.premium"
    case pro = "com.payup.pro"
    case business = "com.payup.business"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .pro: return "Pro"
        case .business: return "Business"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .premium: return "$4.99/mo"
        case .pro: return "$9.99/mo"
        case .business: return "$29.99/mo"
        }
    }

    var yearlyPrice: String? {
        switch self {
        case .free: return nil
        case .premium: return "$39.99/yr"
        case .pro: return "$79.99/yr"
        case .business: return "$299.99/yr"
        }
    }

    var features: [SubscriptionFeature] {
        switch self {
        case .free:
            return [
                .basicExpenseTracking,
                .limitedSessions,
                .limitedGroupMembers,
                .basicSettlements
            ]
        case .premium:
            return [
                .unlimitedSessions,
                .cloudSync,
                .advancedAnalytics,
                .receiptScanning,
                .exportReports,
                .customCategories,
                .recurringExpenses,
                .prioritySupport
            ]
        case .pro:
            return SubscriptionTier.premium.features + [
                .paymentIntegration,
                .multiCurrency,
                .smartSplitting,
                .aiCategorization,
                .widgetSupport,
                .watchApp,
                .customThemes,
                .advancedPrivacy
            ]
        case .business:
            return SubscriptionTier.pro.features + [
                .teamManagement,
                .approvalWorkflows,
                .accountingIntegration,
                .bulkImportExport,
                .adminDashboard,
                .auditLogs,
                .dedicatedSupport,
                .customBranding
            ]
        }
    }
}

// MARK: - Subscription Features
enum SubscriptionFeature: String, CaseIterable {
    // Basic
    case basicExpenseTracking
    case limitedSessions
    case limitedGroupMembers
    case basicSettlements

    // Premium
    case unlimitedSessions
    case cloudSync
    case advancedAnalytics
    case receiptScanning
    case exportReports
    case customCategories
    case recurringExpenses
    case prioritySupport

    // Pro
    case paymentIntegration
    case multiCurrency
    case smartSplitting
    case aiCategorization
    case widgetSupport
    case watchApp
    case customThemes
    case advancedPrivacy

    // Business
    case teamManagement
    case approvalWorkflows
    case accountingIntegration
    case bulkImportExport
    case adminDashboard
    case auditLogs
    case dedicatedSupport
    case customBranding

    var displayName: String {
        switch self {
        case .basicExpenseTracking: return "Basic Expense Tracking"
        case .limitedSessions: return "Limited Sessions"
        case .limitedGroupMembers: return "Limited Group Members"
        case .basicSettlements: return "Basic Settlements"
        case .unlimitedSessions: return "Unlimited Sessions"
        case .cloudSync: return "Cloud Sync & Backup"
        case .advancedAnalytics: return "Advanced Analytics"
        case .receiptScanning: return "Receipt Scanner (OCR)"
        case .exportReports: return "Export Reports (CSV/PDF)"
        case .customCategories: return "Custom Categories"
        case .recurringExpenses: return "Recurring Expenses"
        case .prioritySupport: return "Priority Support"
        case .paymentIntegration: return "Payment Integration"
        case .multiCurrency: return "Multi-Currency Support"
        case .smartSplitting: return "Smart Splitting AI"
        case .aiCategorization: return "AI Categorization"
        case .widgetSupport: return "iOS Widgets"
        case .watchApp: return "Apple Watch App"
        case .customThemes: return "Custom Themes"
        case .advancedPrivacy: return "Advanced Privacy"
        case .teamManagement: return "Team Management"
        case .approvalWorkflows: return "Approval Workflows"
        case .accountingIntegration: return "Accounting Integration"
        case .bulkImportExport: return "Bulk Import/Export"
        case .adminDashboard: return "Admin Dashboard"
        case .auditLogs: return "Audit Logs"
        case .dedicatedSupport: return "Dedicated Support"
        case .customBranding: return "Custom Branding"
        }
    }

    var icon: String {
        switch self {
        case .basicExpenseTracking: return "dollarsign.circle"
        case .limitedSessions, .unlimitedSessions: return "person.3.fill"
        case .limitedGroupMembers: return "person.2.badge.minus"
        case .basicSettlements: return "arrow.left.arrow.right"
        case .cloudSync: return "icloud.and.arrow.up"
        case .advancedAnalytics: return "chart.line.uptrend.xyaxis"
        case .receiptScanning: return "camera.fill"
        case .exportReports: return "square.and.arrow.up"
        case .customCategories: return "tag.fill"
        case .recurringExpenses: return "repeat.circle.fill"
        case .prioritySupport, .dedicatedSupport: return "bubble.left.and.bubble.right.fill"
        case .paymentIntegration: return "creditcard.fill"
        case .multiCurrency: return "dollarsign.arrow.circlepath"
        case .smartSplitting: return "brain"
        case .aiCategorization: return "cpu"
        case .widgetSupport: return "square.stack.3d.up.fill"
        case .watchApp: return "applewatch"
        case .customThemes: return "paintbrush.fill"
        case .advancedPrivacy: return "lock.shield.fill"
        case .teamManagement: return "person.3.sequence.fill"
        case .approvalWorkflows: return "checkmark.shield.fill"
        case .accountingIntegration: return "doc.text.fill"
        case .bulkImportExport: return "square.and.arrow.down.on.square.fill"
        case .adminDashboard: return "speedometer"
        case .auditLogs: return "doc.text.magnifyingglass"
        case .customBranding: return "paintpalette.fill"
        }
    }
}

// MARK: - Subscription Status
struct SubscriptionStatus: Codable {
    let tier: SubscriptionTier
    let isActive: Bool
    let expirationDate: Date?
    let isTrialPeriod: Bool
    let trialExpirationDate: Date?
    let autoRenewEnabled: Bool
    let paymentMethod: PaymentMethodType?

    init(
        tier: SubscriptionTier = .free,
        isActive: Bool = true,
        expirationDate: Date? = nil,
        isTrialPeriod: Bool = false,
        trialExpirationDate: Date? = nil,
        autoRenewEnabled: Bool = false,
        paymentMethod: PaymentMethodType? = nil
    ) {
        self.tier = tier
        self.isActive = isActive
        self.expirationDate = expirationDate
        self.isTrialPeriod = isTrialPeriod
        self.trialExpirationDate = trialExpirationDate
        self.autoRenewEnabled = autoRenewEnabled
        self.paymentMethod = paymentMethod
    }

    var daysUntilExpiration: Int? {
        guard let expirationDate = isTrialPeriod ? trialExpirationDate : expirationDate else {
            return nil
        }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
        return days
    }

    var isExpired: Bool {
        if tier == .free { return false }
        guard let expirationDate = isTrialPeriod ? trialExpirationDate : expirationDate else {
            return false
        }
        return expirationDate < Date()
    }
}

// MARK: - Payment Method Types
enum PaymentMethodType: String, Codable {
    case applePay = "Apple Pay"
    case creditCard = "Credit Card"
    case paypal = "PayPal"
    case googlePay = "Google Pay"

    var icon: String {
        switch self {
        case .applePay: return "applelogo"
        case .creditCard: return "creditcard.fill"
        case .paypal: return "p.circle.fill"
        case .googlePay: return "g.circle.fill"
        }
    }
}

// MARK: - Usage Limits
struct UsageLimits {
    let tier: SubscriptionTier

    var maxSessions: Int? {
        switch tier {
        case .free: return 3
        default: return nil
        }
    }

    var maxGroupMembers: Int? {
        switch tier {
        case .free: return 10
        default: return nil
        }
    }

    var maxReceiptScansPerMonth: Int? {
        switch tier {
        case .free: return 0
        case .premium: return 50
        case .pro: return 500
        case .business: return nil
        }
    }

    var maxExportPerMonth: Int? {
        switch tier {
        case .free: return 0
        case .premium: return 10
        case .pro: return 100
        case .business: return nil
        }
    }

    var hasCloudSync: Bool {
        tier != .free
    }

    var hasPaymentIntegration: Bool {
        tier == .pro || tier == .business
    }

    var hasAdvancedAnalytics: Bool {
        tier != .free
    }

    var hasCustomThemes: Bool {
        tier == .pro || tier == .business
    }
}