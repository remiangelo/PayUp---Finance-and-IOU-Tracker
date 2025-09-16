import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var budgets: [Budget] = []
    @State private var showingAddBudget = false
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var appearAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Budget Summary Card
                        BudgetSummaryCard(budgets: budgets)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appearAnimation)

                        // Period Selector
                        BudgetPeriodSelector(selectedPeriod: $selectedPeriod)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)

                        // Active Budgets
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active Budgets")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.theme.pureWhite)
                                .padding(.horizontal)

                            ForEach(filteredBudgets) { budget in
                                BudgetCard(budget: budget)
                                    .padding(.horizontal)
                                    .opacity(appearAnimation ? 1 : 0)
                                    .offset(y: appearAnimation ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.7)
                                            .delay(0.2 + Double(filteredBudgets.firstIndex(where: { $0.id == budget.id }) ?? 0) * 0.05),
                                        value: appearAnimation
                                    )
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.theme.brightCyan.opacity(0.3), radius: 5)
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(budgets: $budgets)
            }
            .onAppear {
                loadBudgets()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
            }
        }
    }

    private var filteredBudgets: [Budget] {
        budgets.filter { $0.period == selectedPeriod && $0.isActive }
    }

    private func loadBudgets() {
        // Load budgets from Core Data
        let budgetEntities = coreDataManager.fetchBudgets()
        budgets = budgetEntities.map { entity in
            Budget(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                amount: entity.amount,
                categoryId: entity.categoryId,
                period: BudgetPeriod(rawValue: entity.period ?? "monthly") ?? .monthly,
                startDate: entity.startDate ?? Date(),
                endDate: entity.endDate ?? Date()
            )
        }
    }
}

// MARK: - Budget Summary Card

struct BudgetSummaryCard: View {
    let budgets: [Budget]

    private var totalBudget: Double {
        budgets.filter { $0.isActive }.reduce(0) { $0 + $1.amount }
    }

    private var totalSpent: Double {
        // This would be calculated from actual transactions
        totalBudget * 0.65 // Placeholder
    }

    private var percentageUsed: Double {
        guard totalBudget > 0 else { return 0 }
        return (totalSpent / totalBudget) * 100
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan)
                    Text(Currency.usd.format(totalBudget))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.pureWhite)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(Color.theme.sparkOrange)
                    Text(Currency.usd.format(totalSpent))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.pureWhite)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.theme.darkNavy.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: percentageUsed > 80 ?
                                    [Color.theme.sparkOrange, Color.theme.danger] :
                                    [Color.theme.brightCyan, Color.theme.electricBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(percentageUsed / 100, 1.0), height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(Int(percentageUsed))% Used")
                    .font(.caption)
                    .foregroundColor(Color.theme.pureWhite.opacity(0.7))

                Spacer()

                Text("\(Currency.usd.format(totalBudget - totalSpent)) Remaining")
                    .font(.caption)
                    .foregroundColor(Color.theme.brightCyan)
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
        .padding(.horizontal)
    }
}

// MARK: - Budget Period Selector

struct BudgetPeriodSelector: View {
    @Binding var selectedPeriod: BudgetPeriod

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPeriod = period
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: period.icon)
                                .font(.title2)
                            Text(period.rawValue)
                                .font(.caption)
                        }
                        .frame(width: 80, height: 60)
                        .foregroundColor(selectedPeriod == period ? .white : Color.theme.brightCyan)
                        .background(
                            Group {
                                if selectedPeriod == period {
                                    LinearGradient(
                                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .glassCard(cornerRadius: 12)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    let budget: Budget
    @State private var isExpanded = false

    private var spentAmount: Double {
        // This would be calculated from actual transactions
        budget.amount * 0.45 // Placeholder
    }

    private var percentageUsed: Double {
        guard budget.amount > 0 else { return 0 }
        return (spentAmount / budget.amount) * 100
    }

    private var statusColor: Color {
        if percentageUsed >= 100 {
            return Color.theme.danger
        } else if percentageUsed >= 80 {
            return Color.theme.sparkOrange
        } else {
            return Color.theme.brightCyan
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                        .foregroundColor(Color.theme.pureWhite)
                    Text("\(budget.period.rawValue) Budget")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(Currency.usd.format(budget.amount))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.pureWhite)
                    Text("\(Currency.usd.format(spentAmount)) spent")
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.darkNavy.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor)
                        .frame(width: geometry.size.width * min(percentageUsed / 100, 1.0), height: 8)
                }
            }
            .frame(height: 8)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("\(Int(percentageUsed))% Used", systemImage: "chart.pie.fill")
                            .font(.caption)
                        Spacer()
                        Label("\(budget.daysRemaining) days left", systemImage: "calendar")
                            .font(.caption)
                    }
                    .foregroundColor(Color.theme.pureWhite.opacity(0.7))

                    Text("Daily budget: \(Currency.usd.format(budget.dailyBudget))")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .readableGlassCard(cornerRadius: 16)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Add Budget View

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var budgets: [Budget]
    @State private var budgetName = ""
    @State private var budgetAmount = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Name")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)

                            TextField("Monthly Groceries", text: $budgetName, prompt: Text("Monthly Groceries").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)

                            TextField("500", text: $budgetAmount, prompt: Text("500").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                                .keyboardType(.decimalPad)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)

                            BudgetPeriodPicker(selectedPeriod: $selectedPeriod)
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Button {
                        createBudget()
                        dismiss()
                    } label: {
                        Text("Create Budget")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(width: 220, height: 54)
                            .glassCard(cornerRadius: 27)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: Color.theme.brightCyan.opacity(0.3), radius: 15, y: 5)
                    }
                    .disabled(budgetName.isEmpty || budgetAmount.isEmpty)
                    .opacity(budgetName.isEmpty || budgetAmount.isEmpty ? 0.5 : 1)

                    Spacer()
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brightCyan)
                }
            }
        }
    }

    private func createBudget() {
        guard let amount = Double(budgetAmount) else { return }

        let (startDate, endDate) = selectedPeriod.nextPeriodDates()
        let budget = Budget(
            name: budgetName,
            amount: amount,
            categoryId: selectedCategory?.id,
            period: selectedPeriod,
            startDate: startDate,
            endDate: endDate
        )

        budgets.append(budget)

        // Save to Core Data
        _ = CoreDataManager.shared.createBudget(
            name: budgetName,
            amount: amount,
            category: nil,
            period: selectedPeriod.rawValue.lowercased()
        )
    }
}

// MARK: - Budget Period Picker

struct BudgetPeriodPicker: View {
    @Binding var selectedPeriod: BudgetPeriod

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedPeriod == period ? .white : Color.theme.brightCyan)
                            .background(
                                selectedPeriod == period ?
                                LinearGradient(
                                    colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.theme.brightCyan.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(SessionManager())
}