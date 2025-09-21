import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var coreDataManager = CoreDataManager()
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var appearAnimation = false
    @State private var chartData: [ChartDataPoint] = []
    @State private var categoryBreakdown: [(Category, Double)] = []
    @State private var liquidPhase: CGFloat = 0
    @State private var glowPulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium liquid glass background
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: LiquidGlassUI.Spacing.lg) {
                        // Glass Period Selector
                        LiquidPeriodSelector(selectedPeriod: $selectedPeriod)
                            .padding(.horizontal)
                            .padding(.top, LiquidGlassUI.Spacing.md)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : -20)

                        // Premium Spending Overview Card
                        PremiumSpendingOverviewCard(period: selectedPeriod)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)

                        // Liquid Glass Chart
                        LiquidSpendingChart(chartData: chartData, period: selectedPeriod)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearAnimation)

                        // Premium Category Breakdown
                        PremiumCategoryBreakdown(breakdown: categoryBreakdown)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 40)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appearAnimation)

                        // Top Merchants Card
                        TopMerchantsCard()
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 50)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: appearAnimation)

                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadAnalyticsData()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    liquidPhase = .pi * 2
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }

    private func loadAnalyticsData() {
        // Load chart data
        chartData = generateMockChartData()
        // Load category breakdown
        categoryBreakdown = generateMockCategoryData()
    }

    private func generateMockChartData() -> [ChartDataPoint] {
        let days = selectedPeriod == .week ? 7 : selectedPeriod == .month ? 30 : 365
        return (0..<min(days, 12)).map { index in
            ChartDataPoint(
                date: Date().addingTimeInterval(-86400 * Double(days - index)),
                value: Double.random(in: 50...500)
            )
        }
    }

    private func generateMockCategoryData() -> [(Category, Double)] {
        return [
            (Category(name: "Food & Dining", icon: "fork.knife", colorHex: "#34C759"), 450),
            (Category(name: "Transportation", icon: "car.fill", colorHex: "#007AFF"), 280),
            (Category(name: "Entertainment", icon: "tv.fill", colorHex: "#AF52DE"), 150),
            (Category(name: "Shopping", icon: "bag.fill", colorHex: "#FF9500"), 320),
            (Category(name: "Bills", icon: "doc.text.fill", colorHex: "#FF3B30"), 200)
        ]
    }
}

// MARK: - Liquid Period Selector
struct LiquidPeriodSelector: View {
    @Binding var selectedPeriod: AnalyticsPeriod
    @State private var liquidOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Glass background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                        LiquidGlassUI.Colors.neonBlue.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

                // Liquid indicator with glow
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan.opacity(0.4),
                                LiquidGlassUI.Colors.neonBlue.opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width / 3 - 8)
                    .offset(x: liquidOffset + 4)
                    .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.5), radius: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedPeriod)

                // Options
                HStack(spacing: 0) {
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                            let index = AnalyticsPeriod.allCases.firstIndex(of: period) ?? 0
                            liquidOffset = CGFloat(index) * (geometry.size.width / 3)
                        }) {
                            Text(period.rawValue.capitalized)
                                .font(LiquidGlassUI.Typography.callout)
                                .fontWeight(selectedPeriod == period ? .bold : .medium)
                                .foregroundColor(
                                    selectedPeriod == period ?
                                    LiquidGlassUI.Colors.textPrimary :
                                    LiquidGlassUI.Colors.textSecondary
                                )
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 14)
            }
        }
        .frame(height: 56)
    }
}

// MARK: - Premium Spending Overview Card
struct PremiumSpendingOverviewCard: View {
    let period: AnalyticsPeriod
    @State private var animateNumbers = false
    @State private var pulseGlow = false

    private var totalSpent: Double { 2850.0 }
    private var average: Double { totalSpent / 30 }
    private var trend: Double { 12.5 }

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.35,
            cornerRadius: 28,
            glowColor: LiquidGlassUI.Colors.neonPurple,
            showGlow: true
        ) {
            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SPENDING OVERVIEW")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                        Text("\(period.rawValue.capitalized) Total")
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                    }

                    Spacer()

                    // Trend indicator
                    HStack(spacing: 4) {
                        Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(trend > 0 ? LiquidGlassUI.Colors.danger : LiquidGlassUI.Colors.success)

                        Text("\(Int(abs(trend)))%")
                            .font(LiquidGlassUI.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(trend > 0 ? LiquidGlassUI.Colors.danger : LiquidGlassUI.Colors.success)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((trend > 0 ? LiquidGlassUI.Colors.danger : LiquidGlassUI.Colors.success).opacity(0.15))
                    )
                    .scaleEffect(pulseGlow ? 1.05 : 1.0)
                }

                // Main amount with liquid gradient
                Text(String(format: "$%.2f", animateNumbers ? totalSpent : 0))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LiquidGlassUI.Colors.neonCyan,
                                LiquidGlassUI.Colors.neonPurple,
                                LiquidGlassUI.Colors.neonBlue
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: LiquidGlassUI.Colors.neonPurple.opacity(0.5), radius: 15)

                // Stats row
                HStack(spacing: LiquidGlassUI.Spacing.xl) {
                    StatItem(
                        label: "Daily Avg",
                        value: String(format: "$%.0f", average),
                        color: LiquidGlassUI.Colors.neonCyan
                    )

                    // Divider
                    Rectangle()
                        .fill(LiquidGlassUI.Colors.divider)
                        .frame(width: 1, height: 40)

                    StatItem(
                        label: "Transactions",
                        value: "47",
                        color: LiquidGlassUI.Colors.neonBlue
                    )

                    // Divider
                    Rectangle()
                        .fill(LiquidGlassUI.Colors.divider)
                        .frame(width: 1, height: 40)

                    StatItem(
                        label: "Categories",
                        value: "8",
                        color: LiquidGlassUI.Colors.neonPurple
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.7).delay(0.3)) {
                animateNumbers = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(LiquidGlassUI.Typography.caption)
                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

            Text(value)
                .font(LiquidGlassUI.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Liquid Spending Chart
struct LiquidSpendingChart: View {
    let chartData: [ChartDataPoint]
    let period: AnalyticsPeriod
    @State private var animateChart = false

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.25,
            cornerRadius: 24,
            glowColor: LiquidGlassUI.Colors.neonBlue
        ) {
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                Text("Spending Trend")
                    .font(LiquidGlassUI.Typography.headline)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                if !chartData.isEmpty {
                    Chart(chartData) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Amount", animateChart ? point.value : 0)
                        )
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
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .shadow(color: LiquidGlassUI.Colors.neonBlue.opacity(0.5), radius: 5)

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Amount", animateChart ? point.value : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                    LiquidGlassUI.Colors.neonBlue.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel()
                                .foregroundStyle(LiquidGlassUI.Colors.textTertiary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel()
                                .foregroundStyle(LiquidGlassUI.Colors.textTertiary)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.7).delay(0.5)) {
                animateChart = true
            }
        }
    }
}

// MARK: - Premium Category Breakdown
struct PremiumCategoryBreakdown: View {
    let breakdown: [(Category, Double)]
    @State private var expandCards = false

    private var total: Double {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.3,
            cornerRadius: 24,
            glowColor: LiquidGlassUI.Colors.neonPurple
        ) {
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.lg) {
                Text("Category Breakdown")
                    .font(LiquidGlassUI.Typography.headline)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                VStack(spacing: LiquidGlassUI.Spacing.md) {
                    ForEach(Array(breakdown.enumerated()), id: \.offset) { index, item in
                        CategoryRow(
                            category: item.0,
                            amount: item.1,
                            percentage: (item.1 / total) * 100,
                            delay: Double(index) * 0.1
                        )
                        .opacity(expandCards ? 1 : 0)
                        .offset(x: expandCards ? 0 : -30)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                expandCards = true
            }
        }
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: Category
    let amount: Double
    let percentage: Double
    let delay: Double
    @State private var expandBar = false

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.sm) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .fill(category.color.opacity(0.2))
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(LiquidGlassUI.Typography.callout)
                        .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                    Text("\(Int(percentage))%")
                        .font(LiquidGlassUI.Typography.caption)
                        .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                }

                Spacer()

                Text(String(format: "$%.0f", amount))
                    .font(LiquidGlassUI.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(category.color)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.3))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.color,
                                    category.color.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: expandBar ? geometry.size.width * (percentage / 100) : 0)
                        .shadow(color: category.color.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 6)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(delay + 0.5)) {
                expandBar = true
            }
        }
    }
}

// MARK: - Top Merchants Card
struct TopMerchantsCard: View {
    @State private var merchants = [
        ("Starbucks", 185.50, "cup.and.saucer.fill"),
        ("Uber", 142.00, "car.fill"),
        ("Amazon", 89.99, "cart.fill"),
        ("Netflix", 15.99, "tv.fill"),
        ("Whole Foods", 234.67, "basket.fill")
    ]

    var body: some View {
        PremiumGlassCard(
            glassIntensity: 0.25,
            cornerRadius: 24,
            glowColor: LiquidGlassUI.Colors.neonCyan
        ) {
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.lg) {
                Text("Top Merchants")
                    .font(LiquidGlassUI.Typography.headline)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                VStack(spacing: LiquidGlassUI.Spacing.md) {
                    ForEach(Array(merchants.prefix(5).enumerated()), id: \.offset) { index, merchant in
                        HStack {
                            // Rank
                            Text("#\(index + 1)")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                                .frame(width: 30)

                            // Icon
                            Image(systemName: merchant.2)
                                .font(.system(size: 16))
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                                .frame(width: 24)

                            Text(merchant.0)
                                .font(LiquidGlassUI.Typography.callout)
                                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                            Spacer()

                            Text(String(format: "$%.2f", merchant.1))
                                .font(LiquidGlassUI.Typography.callout)
                                .fontWeight(.semibold)
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
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum AnalyticsPeriod: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
}

#Preview {
    AnalyticsView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}