import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var currentSubscription: SubscriptionStatus
    @Published var availableProducts: [Product] = []
    @Published var purchasedProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var usageStats: UsageStatistics
    @Published var showPaywall = false

    private var updateListenerTask: Task<Void, Error>?
    private let userDefaults = UserDefaults.standard
    private let subscriptionKey = "CurrentSubscription"
    private let usageKey = "UsageStatistics"

    // Product IDs for App Store
    private let productIds = [
        "com.payup.premium.monthly",
        "com.payup.premium.yearly",
        "com.payup.pro.monthly",
        "com.payup.pro.yearly",
        "com.payup.business.monthly",
        "com.payup.business.yearly"
    ]

    init() {
        // Load saved subscription status
        if let savedData = userDefaults.data(forKey: subscriptionKey),
           let subscription = try? JSONDecoder().decode(SubscriptionStatus.self, from: savedData) {
            self.currentSubscription = subscription
        } else {
            self.currentSubscription = SubscriptionStatus(tier: .free)
        }

        // Load usage statistics
        if let usageData = userDefaults.data(forKey: usageKey),
           let usage = try? JSONDecoder().decode(UsageStatistics.self, from: usageData) {
            self.usageStats = usage
        } else {
            self.usageStats = UsageStatistics()
        }

        // Start transaction listener
        updateListenerTask = listenForTransactions()

        // Load products from App Store
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - StoreKit Integration

    @MainActor
    func loadProducts() async {
        isLoading = true
        do {
            availableProducts = try await Product.products(for: productIds)
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await updateCustomerProductStatus()
            await transaction.finish()

            isLoading = false
            return transaction

        case .userCancelled, .pending:
            isLoading = false
            return nil
        @unknown default:
            isLoading = false
            return nil
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedProducts: [Product] = []

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if let product = availableProducts.first(where: { $0.id == transaction.productID }) {
                    purchasedProducts.append(product)
                }

                // Update subscription status based on transaction
                updateSubscriptionStatus(from: transaction)
            } catch {
                errorMessage = "Transaction verification failed"
            }
        }

        self.purchasedProducts = purchasedProducts
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    private func updateSubscriptionStatus(from transaction: StoreKit.Transaction) {
        // Parse the product ID to determine tier
        let tier: SubscriptionTier
        if transaction.productID.contains("premium") {
            tier = .premium
        } else if transaction.productID.contains("pro") {
            tier = .pro
        } else if transaction.productID.contains("business") {
            tier = .business
        } else {
            tier = .free
        }

        let expirationDate = transaction.expirationDate

        currentSubscription = SubscriptionStatus(
            tier: tier,
            isActive: transaction.revocationDate == nil,
            expirationDate: expirationDate,
            isTrialPeriod: transaction.offerType == .introductory,
            trialExpirationDate: transaction.offerType == .introductory ? expirationDate : nil,
            autoRenewEnabled: true
        )

        saveSubscriptionStatus()
    }

    // MARK: - Restore Purchases

    @MainActor
    func restorePurchases() async {
        isLoading = true
        try? await AppStore.sync()
        await updateCustomerProductStatus()
        isLoading = false
    }

    // MARK: - Usage Tracking

    func checkLimit(for feature: SubscriptionFeature) -> Bool {
        let limits = UsageLimits(tier: currentSubscription.tier)

        switch feature {
        case .limitedSessions:
            return usageStats.activeSessions < (limits.maxSessions ?? Int.max)
        case .limitedGroupMembers:
            return true // Check in session context
        case .receiptScanning:
            let monthlyScans = usageStats.getMonthlyReceiptScans()
            return monthlyScans < (limits.maxReceiptScansPerMonth ?? Int.max)
        case .exportReports:
            let monthlyExports = usageStats.getMonthlyExports()
            return monthlyExports < (limits.maxExportPerMonth ?? Int.max)
        default:
            return currentSubscription.tier.features.contains(feature)
        }
    }

    func incrementUsage(for feature: SubscriptionFeature) {
        switch feature {
        case .receiptScanning:
            usageStats.incrementReceiptScan()
        case .exportReports:
            usageStats.incrementExport()
        default:
            break
        }
        saveUsageStats()
    }

    func checkAndShowPaywall(for feature: SubscriptionFeature) -> Bool {
        if !checkLimit(for: feature) {
            showPaywall = true
            return false
        }
        return true
    }

    // MARK: - Persistence

    private func saveSubscriptionStatus() {
        if let encoded = try? JSONEncoder().encode(currentSubscription) {
            userDefaults.set(encoded, forKey: subscriptionKey)
        }
    }

    private func saveUsageStats() {
        if let encoded = try? JSONEncoder().encode(usageStats) {
            userDefaults.set(encoded, forKey: usageKey)
        }
    }

    // MARK: - Trial Management

    func startFreeTrial(for tier: SubscriptionTier) {
        let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days

        currentSubscription = SubscriptionStatus(
            tier: tier,
            isActive: true,
            expirationDate: nil,
            isTrialPeriod: true,
            trialExpirationDate: Date().addingTimeInterval(trialDuration),
            autoRenewEnabled: false
        )

        saveSubscriptionStatus()
    }

    // MARK: - Pricing Helpers

    func getPriceString(for product: Product) -> String {
        product.displayPrice
    }

    func getMonthlyEquivalent(for product: Product) -> String? {
        if product.id.contains("yearly") {
            let monthlyPrice = product.price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatStyle.locale
            return formatter.string(from: NSNumber(value: Double(truncating: monthlyPrice as NSNumber)))
        }
        return nil
    }

    func getSavingsPercentage(monthly: Product, yearly: Product) -> Int {
        let monthlyTotal = monthly.price * 12
        let yearlyPrice = yearly.price
        let savings = monthlyTotal - yearlyPrice
        let percentage = (savings / monthlyTotal) * 100
        return Int((percentage as NSDecimalNumber).doubleValue.rounded())
    }
}

// MARK: - Usage Statistics
struct UsageStatistics: Codable {
    var activeSessions: Int = 0
    var totalTransactions: Int = 0
    var receiptScans: [Date] = []
    var exports: [Date] = []
    var lastActiveDate: Date = Date()

    mutating func incrementReceiptScan() {
        receiptScans.append(Date())
        cleanOldEntries()
    }

    mutating func incrementExport() {
        exports.append(Date())
        cleanOldEntries()
    }

    func getMonthlyReceiptScans() -> Int {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return receiptScans.filter { $0 >= startOfMonth }.count
    }

    func getMonthlyExports() -> Int {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return exports.filter { $0 >= startOfMonth }.count
    }

    private mutating func cleanOldEntries() {
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        receiptScans = receiptScans.filter { $0 > twoMonthsAgo }
        exports = exports.filter { $0 > twoMonthsAgo }
    }
}

// MARK: - Store Errors
enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
}