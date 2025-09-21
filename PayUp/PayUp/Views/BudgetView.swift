import SwiftUI
import Charts

struct BudgetView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var coreDataManager = CoreDataManager()
    @State private var budgets: [Budget] = []
    @State private var showingAddBudget = false
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var appearAnimation = false
    @State private var pulseAnimation = false
    @State private var liquidPhase: CGFloat = 0

    var filteredBudgets: [Budget] {
        budgets.filter { $0.period == selectedPeriod }
    }

    var totalBudget: Double {
        filteredBudgets.reduce(0) { $0 + $1.amount }
    }

    var totalSpent: Double {
        // For now, return mock data since we need transactions to calculate actual spent
        filteredBudgets.reduce(0) { $0 + ($1.amount * 0.65) } // Mock 65% spent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium liquid glass background
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: LiquidGlassUI.Spacing.lg) {
                        // Premium Budget Summary Card
                        PremiumBudgetSummaryCard(
                            totalBudget: totalBudget,
                            totalSpent: totalSpent
                        )
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -30)

                        // Glass Period Selector
                        GlassPeriodSelector(selectedPeriod: $selectedPeriod)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)

                        // Budget Items with liquid glass cards
                        VStack(spacing: LiquidGlassUI.Spacing.md) {
                            if filteredBudgets.isEmpty {
                                EmptyBudgetState()
                                    .padding(.top, 50)
                            } else {
                                ForEach(Array(filteredBudgets.enumerated()), id: \.element.id) { index, budget in
                                    LiquidBudgetCard(budget: budget)
                                        .opacity(appearAnimation ? 1 : 0)
                                        .offset(y: appearAnimation ? 0 : 30)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.7)
                                            .delay(Double(index) * 0.1 + 0.2),
                                            value: appearAnimation
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                                    LiquidGlassUI.Colors.neonBlue.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.4), radius: 8)

                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetSheet(budgets: $budgets)
                    .background(LiquidGlassBackground())
            }
            .onAppear {
                loadBudgets()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    liquidPhase = .pi * 2
                }
            }
        }
    }

    private func loadBudgets() {
        // Mock data for now
        budgets = [
            Budget(name: "Food & Dining", amount: 500, period: .monthly),
            Budget(name: "Transportation", amount: 200, period: .monthly),
            Budget(name: "Entertainment", amount: 150, period: .monthly)
        ]
    }
}

// MARK: - Premium Budget Summary Card
struct PremiumBudgetSummaryCard: View {
    let totalBudget: Double
    let totalSpent: Double

    @State private var progressAnimation: CGFloat = 0
    @State private var glowPulse = false

    private var percentageUsed: Double {
        guard totalBudget > 0 else { return 0 }
        return min((totalSpent / totalBudget) * 100, 100)
    }

    private var remaining: Double {
        max(totalBudget - totalSpent, 0)
    }

    private var statusColor: Color {
        if percentageUsed < 50 {
            return LiquidGlassUI.Colors.success
        } else if percentageUsed < 80 {
            return LiquidGlassUI.Colors.warning
        } else {
            return LiquidGlassUI.Colors.danger
        }
    }

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.35,
            cornerRadius: 32,
            glowColor: statusColor
        ) {
            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BUDGET OVERVIEW")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                        Text("This Month")
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                    }

                    Spacer()

                    // Percentage indicator
                    ZStack {
                        Circle()
                            .stroke(LiquidGlassUI.Colors.deepOcean.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: progressAnimation)
                            .stroke(
                                AngularGradient(
                                    colors: [statusColor, statusColor.opacity(0.5), statusColor],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: statusColor, radius: 5)

                        Text("\(Int(percentageUsed))%")
                            .font(LiquidGlassUI.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)
                    }
                    .scaleEffect(glowPulse ? 1.05 : 1.0)
                }

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                LiquidGlassUI.Colors.divider,
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                // Stats
                HStack(spacing: LiquidGlassUI.Spacing.xl) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LiquidGlassUI.Colors.neonCyan)
                                .frame(width: 8, height: 8)
                            Text("Budget")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                        }

                        Text(String(format: "$%.0f", totalBudget))
                            .font(LiquidGlassUI.Typography.title)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        LiquidGlassUI.Colors.textPrimary,
                                        LiquidGlassUI.Colors.neonCyan
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            Text("Spent")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                        }

                        Text(String(format: "$%.0f", totalSpent))
                            .font(LiquidGlassUI.Typography.title)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LiquidGlassUI.Colors.success)
                                .frame(width: 8, height: 8)
                            Text("Remaining")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                        }

                        Text(String(format: "$%.0f", remaining))
                            .font(LiquidGlassUI.Typography.title)
                            .fontWeight(.bold)
                            .foregroundColor(LiquidGlassUI.Colors.success)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.7).delay(0.3)) {
                progressAnimation = percentageUsed / 100
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Glass Period Selector
struct GlassPeriodSelector: View {
    @Binding var selectedPeriod: BudgetPeriod
    @State private var liquidOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background glass
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LiquidGlassUI.Colors.divider, lineWidth: 0.5)
                    )

                // Liquid selection indicator
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                LiquidGlassUI.Colors.neonBlue.opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width / 3 - 8)
                    .offset(x: liquidOffset + 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedPeriod)

                // Period options
                HStack(spacing: 0) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                            let index = BudgetPeriod.allCases.firstIndex(of: period) ?? 0
                            liquidOffset = CGFloat(index) * (geometry.size.width / 3)
                        }) {
                            Text(period.rawValue.capitalized)
                                .font(LiquidGlassUI.Typography.callout)
                                .fontWeight(selectedPeriod == period ? .semibold : .regular)
                                .foregroundColor(
                                    selectedPeriod == period ?
                                    LiquidGlassUI.Colors.neonCyan :
                                    LiquidGlassUI.Colors.textSecondary
                                )
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .frame(height: 48)
        .padding(.horizontal)
        .onAppear {
            // Use GeometryReader to get the actual width instead of deprecated UIScreen.main
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        let index = BudgetPeriod.allCases.firstIndex(of: selectedPeriod) ?? 0
                        liquidOffset = CGFloat(index) * (geometry.size.width) / 3
                    }
            }
        )
    }
}

// MARK: - Liquid Budget Card
struct LiquidBudgetCard: View {
    let budget: Budget
    @State private var expandAnimation = false
    @State private var shimmerPhase: CGFloat = -1

    // Mock spent amount (65% of budget)
    private var spent: Double {
        budget.amount * 0.65
    }

    private var percentageUsed: Double {
        guard budget.amount > 0 else { return 0 }
        return min((spent / budget.amount) * 100, 100)
    }

    private var statusColor: Color {
        if percentageUsed < 50 {
            return LiquidGlassUI.Colors.success
        } else if percentageUsed < 80 {
            return LiquidGlassUI.Colors.warning
        } else {
            return LiquidGlassUI.Colors.danger
        }
    }

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.25,
            cornerRadius: 20,
            glowColor: statusColor,
            showGlow: percentageUsed > 80
        ) {
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                // Header
                HStack {
                    // Category icon
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .fill(statusColor.opacity(0.2))
                            )

                        Image(systemName: categoryIcon(for: budget.name))
                            .font(.system(size: 20))
                            .foregroundColor(statusColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(budget.name)
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                        Text("\(Int(percentageUsed))% used")
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.0f", spent))
                            .font(LiquidGlassUI.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)

                        Text(String(format: "of $%.0f", budget.amount))
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.3))
                            .frame(height: 10)

                        // Progress with liquid animation
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        statusColor,
                                        statusColor.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: expandAnimation ? geometry.size.width * (percentageUsed / 100) : 0, height: 10)
                            .shadow(color: statusColor, radius: 4)

                        // Shimmer effect
                        if expandAnimation {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.clear, location: max(0, shimmerPhase - 0.1)),
                                            .init(color: Color.white.opacity(0.3), location: shimmerPhase),
                                            .init(color: Color.clear, location: min(1, shimmerPhase + 0.1))
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (percentageUsed / 100), height: 10)
                        }
                    }
                }
                .frame(height: 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                expandAnimation = true
            }
            withAnimation(.linear(duration: 2).delay(0.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.5
            }
        }
    }

    private func categoryIcon(for name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("food") || lowercased.contains("dining") {
            return "fork.knife"
        } else if lowercased.contains("transport") || lowercased.contains("travel") {
            return "car.fill"
        } else if lowercased.contains("entertainment") {
            return "tv.fill"
        } else if lowercased.contains("shopping") {
            return "bag.fill"
        } else if lowercased.contains("bills") || lowercased.contains("utilities") {
            return "doc.text.fill"
        } else {
            return "banknote.fill"
        }
    }
}

// MARK: - Empty Budget State
struct EmptyBudgetState: View {
    @State private var floatAnimation = false

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 10)

                Image(systemName: "chart.pie")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan,
                                LiquidGlassUI.Colors.neonBlue
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: floatAnimation ? -5 : 5)
            }

            Text("No budgets yet")
                .font(LiquidGlassUI.Typography.headline)
                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

            Text("Create your first budget to start tracking expenses")
                .font(LiquidGlassUI.Typography.body)
                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LiquidGlassUI.Spacing.xl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatAnimation = true
            }
        }
    }
}

// MARK: - Add Budget Sheet
struct AddBudgetSheet: View {
    @Binding var budgets: [Budget]
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var limit = ""
    @State private var period: BudgetPeriod = .monthly

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                VStack(spacing: LiquidGlassUI.Spacing.lg) {
                    // Form fields
                    VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                        Text("Budget Name")
                            .font(LiquidGlassUI.Typography.callout)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)

                        GlassTextField(placeholder: "e.g., Food & Dining", text: $name)

                        Text("Monthly Limit")
                            .font(LiquidGlassUI.Typography.callout)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                            .padding(.top)

                        GlassTextField(placeholder: "Enter amount", text: $limit)

                        Text("Period")
                            .font(LiquidGlassUI.Typography.callout)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                            .padding(.top)

                        GlassPeriodSelector(selectedPeriod: $period)
                    }
                    .padding()

                    Spacer()

                    // Action buttons
                    HStack(spacing: LiquidGlassUI.Spacing.md) {
                        LiquidButton("Cancel", style: .secondary) {
                            dismiss()
                        }

                        LiquidButton("Create Budget", style: .primary) {
                            // Create budget logic
                            dismiss()
                        }
                        .disabled(name.isEmpty || limit.isEmpty)
                        .opacity(name.isEmpty || limit.isEmpty ? 0.6 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}