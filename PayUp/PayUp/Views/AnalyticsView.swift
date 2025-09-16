import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var coreDataManager = CoreDataManager()
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var appearAnimation = false
    @State private var chartData: [ChartDataPoint] = []
    @State private var categoryBreakdown: [(Category, Double)] = []

    var body: some View {
        ZStack {
            WallpaperBackground()

            VStack(spacing: 0) {
                // Title at top
                Text("Analytics")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.theme.pureWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 16)

                // Fixed Period Selector at top
                AnalyticsPeriodSelector(selectedPeriod: $selectedPeriod)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)

                ScrollView {
                    VStack(spacing: 20) {
                        // Spending Overview Card
                        SpendingOverviewCard(period: selectedPeriod)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)

                        // Spending Chart
                        SpendingChartCard(chartData: chartData, period: selectedPeriod)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearAnimation)

                        // Category Breakdown
                        CategoryBreakdownCard(breakdown: categoryBreakdown)
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appearAnimation)

                        // Insights
                        InsightsCard()
                            .padding(.horizontal)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: appearAnimation)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            loadAnalyticsData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearAnimation = true
            }
        }
    }

    private func loadAnalyticsData() {
        // Generate sample data for now
        chartData = generateSampleChartData()
        categoryBreakdown = generateSampleCategoryData()
    }

    private func generateSampleChartData() -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                data.append(ChartDataPoint(
                    date: date,
                    amount: Double.random(in: 20...200)
                ))
            }
        }

        return data.reversed()
    }

    private func generateSampleCategoryData() -> [(Category, Double)] {
        return [
            (Category.defaultCategories[0], 450.0),
            (Category.defaultCategories[1], 280.0),
            (Category.defaultCategories[2], 320.0),
            (Category.defaultCategories[3], 150.0),
            (Category.defaultCategories[4], 200.0)
        ]
    }
}

// MARK: - Analytics Period

enum AnalyticsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"

    var icon: String {
        switch self {
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .year: return "calendar.circle"
        case .all: return "infinity"
        }
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

// MARK: - Period Selector

struct AnalyticsPeriodSelector: View {
    @Binding var selectedPeriod: AnalyticsPeriod

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: period.icon)
                            .font(.title3)
                        Text(period.rawValue)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedPeriod == period ? Color.theme.darkNavy : Color.theme.pureWhite.opacity(0.7))
                    .background(
                        Capsule()
                            .fill(
                                selectedPeriod == period ?
                                AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                ) : AnyShapeStyle(Color.clear)
                            )
                            .overlay(
                                selectedPeriod != period ?
                                Capsule()
                                    .strokeBorder(Color.theme.brightCyan.opacity(0.3), lineWidth: 1) :
                                nil
                            )
                    )
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.theme.darkNavy.opacity(0.8))
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.theme.brightCyan.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Spending Overview Card

struct SpendingOverviewCard: View {
    let period: AnalyticsPeriod
    @State private var animateValue = false

    private var totalSpent: Double { 2847.50 } // Sample data
    private var averageDaily: Double { 94.92 }
    private var trend: Double { -12.5 }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundColor(Color.theme.pureWhite.opacity(0.6))
                    Text(Currency.usd.format(animateValue ? totalSpent : 0))
                        .font(.system(size: 32, weight: .bold))
                        .refractiveText()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: trend < 0 ? "arrow.down" : "arrow.up")
                            .font(.caption)
                        Text("\(abs(trend), specifier: "%.1f")%")
                            .font(.caption)
                    }
                    .foregroundColor(trend < 0 ? Color.theme.success : Color.theme.danger)

                    Text("vs last \(period.rawValue.lowercased())")
                        .font(.caption2)
                        .foregroundColor(Color.theme.pureWhite.opacity(0.6))
                }
            }

            Divider()
                .background(Color.theme.brightCyan.opacity(0.3))

            HStack(spacing: 20) {
                StatItem(
                    title: "Daily Avg",
                    value: Currency.usd.format(averageDaily),
                    icon: "calendar.day.timeline.left"
                )

                StatItem(
                    title: "Transactions",
                    value: "47",
                    icon: "arrow.left.arrow.right"
                )

                StatItem(
                    title: "Categories",
                    value: "8",
                    icon: "square.grid.2x2"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.darkNavy.opacity(0.9))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.theme.brightCyan.opacity(0.2), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateValue = true
            }
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.theme.brightCyan)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.theme.pureWhite)

            Text(title)
                .font(.caption2)
                .foregroundColor(Color.theme.pureWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Spending Chart Card

struct SpendingChartCard: View {
    let chartData: [ChartDataPoint]
    let period: AnalyticsPeriod
    @State private var selectedPoint: ChartDataPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trend")
                .font(.headline)
                .foregroundColor(Color.theme.pureWhite)

            Chart(chartData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.theme.brightCyan.opacity(0.3),
                            Color.theme.electricBlue.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                if let selected = selectedPoint, selected.id == point.id {
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Amount", point.amount)
                    )
                    .foregroundStyle(Color.theme.brightCyan)
                    .symbolSize(100)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption)
                                .foregroundColor(Color.theme.pureWhite.opacity(0.6))
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.theme.brightCyan.opacity(0.1))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day())
                                .font(.caption)
                                .foregroundColor(Color.theme.pureWhite.opacity(0.6))
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.theme.brightCyan.opacity(0.1))
                }
            }
            .chartBackground { chartProxy in
                Color.clear
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.darkNavy.opacity(0.9))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.theme.brightCyan.opacity(0.2), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Category Breakdown Card

struct CategoryBreakdownCard: View {
    let breakdown: [(Category, Double)]
    @State private var selectedCategory: Category?

    private var total: Double {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(Color.theme.pureWhite)

            VStack(spacing: 12) {
                ForEach(breakdown, id: \.0.id) { category, amount in
                    CategoryRow(
                        category: category,
                        amount: amount,
                        percentage: (amount / total) * 100,
                        isSelected: selectedCategory?.id == category.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedCategory?.id == category.id {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.darkNavy.opacity(0.9))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.theme.brightCyan.opacity(0.2), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    let amount: Double
    let percentage: Double
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(category.color)
                .frame(width: 40, height: 40)
                .background(category.color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.pureWhite)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.theme.darkNavy.opacity(0.3))
                            .frame(height: 6)

                        Capsule()
                            .fill(category.color)
                            .frame(width: geometry.size.width * (percentage / 100), height: 6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: percentage)
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(Currency.usd.format(amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.pureWhite)

                Text("\(percentage, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(Color.theme.pureWhite.opacity(0.6))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? category.color.opacity(0.1) : Color.clear)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - Insights Card

struct InsightsCard: View {
    @State private var currentInsight = 0
    let insights = [
        Insight(
            icon: "lightbulb.fill",
            title: "Spending Trend",
            description: "You've reduced spending by 12% this month!",
            type: .positive
        ),
        Insight(
            icon: "cart.fill",
            title: "Top Category",
            description: "Food & Dining is your highest expense at 35%",
            type: .neutral
        ),
        Insight(
            icon: "exclamationmark.triangle.fill",
            title: "Budget Alert",
            description: "Entertainment budget 80% used with 10 days left",
            type: .warning
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(Color.theme.pureWhite)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<insights.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentInsight ? Color.theme.brightCyan : Color.theme.pureWhite.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }

            TabView(selection: $currentInsight) {
                ForEach(0..<insights.count, id: \.self) { index in
                    InsightRow(insight: insights[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 80)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.darkNavy.opacity(0.9))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.theme.brightCyan.opacity(0.2), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    currentInsight = (currentInsight + 1) % insights.count
                }
            }
        }
    }
}

// MARK: - Insight Model

struct Insight {
    let icon: String
    let title: String
    let description: String
    let type: InsightType

    enum InsightType {
        case positive, neutral, warning

        var color: Color {
            switch self {
            case .positive: return Color.theme.success
            case .neutral: return Color.theme.brightCyan
            case .warning: return Color.theme.sparkOrange
            }
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.type.color)
                .frame(width: 44, height: 44)
                .background(insight.type.color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.pureWhite)

                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(Color.theme.pureWhite.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer()
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(SessionManager())
}