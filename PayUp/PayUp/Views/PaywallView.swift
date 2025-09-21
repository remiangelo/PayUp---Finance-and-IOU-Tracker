import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionTier = .premium
    @State private var isYearly = false
    @State private var showingPurchaseAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium liquid glass background
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: LiquidGlassUI.Spacing.xl) {
                        // Header
                        PaywallHeader()
                            .padding(.top, LiquidGlassUI.Spacing.xl)

                        // Plan Selector
                        PlanSelector(selectedPlan: $selectedPlan)
                            .padding(.horizontal)

                        // Billing Period Toggle
                        BillingToggle(isYearly: $isYearly)
                            .padding(.horizontal)

                        // Features List
                        FeaturesListView(plan: selectedPlan)
                            .padding(.horizontal)

                        // Price and Purchase Button
                        PurchaseSection(
                            plan: selectedPlan,
                            isYearly: isYearly,
                            onPurchase: { await purchaseSubscription() }
                        )
                        .padding(.horizontal)

                        // Restore Purchases
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }
                        .font(LiquidGlassUI.Typography.caption)
                        .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                        .padding(.bottom, LiquidGlassUI.Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                }
            }
            .alert("Purchase Status", isPresented: $showingPurchaseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    @MainActor
    private func purchaseSubscription() async {
        guard let product = subscriptionManager.availableProducts.first(where: { product in
            product.id.contains(selectedPlan.rawValue.replacingOccurrences(of: "com.payup.", with: "")) &&
            product.id.contains(isYearly ? "yearly" : "monthly")
        }) else {
            alertMessage = "Product not found"
            showingPurchaseAlert = true
            return
        }

        do {
            if let transaction = try await subscriptionManager.purchase(product) {
                alertMessage = "Successfully upgraded to \(selectedPlan.displayName)!"
                showingPurchaseAlert = true
                dismiss()
            }
        } catch {
            alertMessage = "Purchase failed: \(error.localizedDescription)"
            showingPurchaseAlert = true
        }
    }
}

// MARK: - Header
struct PaywallHeader: View {
    @State private var glowAnimation = false

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                LiquidGlassUI.Colors.neonBlue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(glowAnimation ? 1.2 : 0.9)

                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan,
                                LiquidGlassUI.Colors.neonPurple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowAnimation = true
                }
            }

            // Title
            VStack(spacing: LiquidGlassUI.Spacing.sm) {
                Text("Upgrade to Premium")
                    .font(LiquidGlassUI.Typography.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.textPrimary,
                                LiquidGlassUI.Colors.neonCyan
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("Unlock powerful features and remove all limits")
                    .font(LiquidGlassUI.Typography.body)
                    .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Plan Selector
struct PlanSelector: View {
    @Binding var selectedPlan: SubscriptionTier
    let plans: [SubscriptionTier] = [.premium, .pro, .business]

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.md) {
            ForEach(plans, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    onSelect: { selectedPlan = plan }
                )
            }
        }
    }
}

struct PlanCard: View {
    let plan: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            PremiumGlassCard(
                glowColor: isSelected ? LiquidGlassUI.Colors.neonCyan : LiquidGlassUI.Colors.neonBlue.opacity(0.3),
                showGlow: isSelected
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                        Text(plan.displayName)
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(isSelected ? LiquidGlassUI.Colors.neonCyan : LiquidGlassUI.Colors.textPrimary)

                        Text(plan == .premium ? "Most Popular" : plan == .business ? "For Teams" : "Advanced")
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Billing Toggle
struct BillingToggle: View {
    @Binding var isYearly: Bool

    var body: some View {
        PremiumGlassCard {
            HStack {
                Text("Monthly")
                    .font(LiquidGlassUI.Typography.callout)
                    .fontWeight(isYearly ? .regular : .semibold)
                    .foregroundColor(isYearly ? LiquidGlassUI.Colors.textTertiary : LiquidGlassUI.Colors.neonCyan)

                Toggle("", isOn: $isYearly)
                    .toggleStyle(LiquidToggleStyle())
                    .labelsHidden()

                Text("Yearly")
                    .font(LiquidGlassUI.Typography.callout)
                    .fontWeight(isYearly ? .semibold : .regular)
                    .foregroundColor(isYearly ? LiquidGlassUI.Colors.neonCyan : LiquidGlassUI.Colors.textTertiary)

                if isYearly {
                    Text("Save 33%")
                        .font(LiquidGlassUI.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(LiquidGlassUI.Colors.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LiquidGlassUI.Colors.success.opacity(0.2))
                        )
                }
            }
        }
    }
}

// MARK: - Liquid Toggle Style
struct LiquidToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Capsule()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 32)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    LiquidGlassUI.Colors.neonCyan.opacity(0.5),
                                    LiquidGlassUI.Colors.neonBlue.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )

            HStack {
                if configuration.isOn {
                    Spacer()
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: configuration.isOn ?
                                [LiquidGlassUI.Colors.neonCyan, LiquidGlassUI.Colors.neonBlue] :
                                [LiquidGlassUI.Colors.textTertiary, LiquidGlassUI.Colors.textSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)
                    .shadow(color: configuration.isOn ? LiquidGlassUI.Colors.neonCyan.opacity(0.5) : Color.clear, radius: 5)

                if !configuration.isOn {
                    Spacer()
                }
            }
            .padding(.horizontal, 3)
        }
        .frame(width: 60, height: 32)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Features List
struct FeaturesListView: View {
    let plan: SubscriptionTier

    var body: some View {
        PremiumGlassCard {
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                Text("Included Features")
                    .font(LiquidGlassUI.Typography.headline)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                ForEach(plan.features.prefix(8), id: \.self) { feature in
                    HStack(spacing: LiquidGlassUI.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(LiquidGlassUI.Colors.success)

                        Text(feature.displayName)
                            .font(LiquidGlassUI.Typography.body)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)

                        Spacer()
                    }
                }

                if plan.features.count > 8 {
                    Text("+ \(plan.features.count - 8) more features")
                        .font(LiquidGlassUI.Typography.caption)
                        .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                }
            }
        }
    }
}

// MARK: - Purchase Section
struct PurchaseSection: View {
    let plan: SubscriptionTier
    let isYearly: Bool
    let onPurchase: () async -> Void
    @State private var isProcessing = false

    var priceText: String {
        if isYearly {
            return plan.yearlyPrice ?? plan.price
        }
        return plan.price
    }

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.md) {
            // Price
            VStack(spacing: LiquidGlassUI.Spacing.xs) {
                Text(priceText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan,
                                LiquidGlassUI.Colors.neonBlue
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                if isYearly {
                    Text("That's only \(plan.price.replacingOccurrences(of: "/mo", with: "")) per month")
                        .font(LiquidGlassUI.Typography.caption)
                        .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                }
            }

            // Purchase Button
            Button(action: {
                isProcessing = true
                Task {
                    await onPurchase()
                    isProcessing = false
                }
            }) {
                ZStack {
                    if isProcessing {
                        LiquidLoader()
                    } else {
                        HStack {
                            Text("Start Free Trial")
                                .font(LiquidGlassUI.Typography.headline)
                                .fontWeight(.semibold)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            LiquidGlassUI.Colors.neonCyan,
                            LiquidGlassUI.Colors.neonBlue
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.5), radius: 15)
            }
            .disabled(isProcessing)
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}