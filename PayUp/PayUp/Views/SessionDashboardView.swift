import SwiftUI

struct SessionDashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0

    private let tabs = [
        FrostedGlassTabBar.TabItem(icon: "list.bullet", title: "Transactions"),
        FrostedGlassTabBar.TabItem(icon: "chart.pie.fill", title: "Balances"),
        FrostedGlassTabBar.TabItem(icon: "chart.line.uptrend.xyaxis", title: "Analytics"),
        FrostedGlassTabBar.TabItem(icon: "arrow.left.arrow.right.circle", title: "Settle"),
        FrostedGlassTabBar.TabItem(icon: "person.3.fill", title: "Session")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                // Liquid animation background layer
                LiquidAnimationContainer {
                    Color.clear
                }
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    // Main content with tab switching
                    TabView(selection: $selectedTab) {
                        TransactionsListView()
                            .tag(0)
                        BalancesView()
                            .tag(1)
                        AnalyticsView()
                            .tag(2)
                        SettlementsView()
                            .tag(3)
                        SessionInfoView()
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)

                    Spacer(minLength: 90) // Space for tab bar
                }

                // Floating custom tab bar
                VStack {
                    Spacer()
                    FrostedGlassTabBar(selectedTab: $selectedTab, tabs: tabs)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
                }
            }
            .navigationTitle(sessionManager.currentSession?.name ?? "Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Session status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.theme.success)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .fill(Color.theme.success)
                                    .frame(width: 8, height: 8)
                                    .blur(radius: 2)
                                    .scaleEffect(1.5)
                                    .opacity(0.5)
                            )

                        Text("Active")
                            .font(.caption)
                            .foregroundColor(Color.theme.pureWhite.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .liquidGlass(intensity: 0.3, cornerRadius: 12)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        ZStack {
                            // Animated background glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.theme.brightCyan.opacity(0.4),
                                            Color.theme.electricBlue.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 20
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .blur(radius: 4)

                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .scaleEffect(showingAddTransaction ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingAddTransaction)
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(sessionManager)
            }
        }
    }
}

// MARK: - Enhanced Transaction List View

extension TransactionsListView {
    func enhancedCard() -> some View {
        self
            .liquidGlass(intensity: 0.3, cornerRadius: 20)
            .interactiveGlass(cornerRadius: 20)
    }
}

// MARK: - Quick Stats Bar

struct QuickStatsBar: View {
    let totalSpent: Double
    let activeUsers: Int
    let pendingSettlements: Int

    var body: some View {
        HStack(spacing: 0) {
            StatWidget(
                title: "Total",
                value: Currency.usd.format(totalSpent),
                color: Color.theme.brightCyan
            )

            Divider()
                .background(Color.theme.brightCyan.opacity(0.3))
                .frame(height: 30)

            StatWidget(
                title: "Active",
                value: "\(activeUsers)",
                color: Color.theme.electricBlue
            )

            Divider()
                .background(Color.theme.brightCyan.opacity(0.3))
                .frame(height: 30)

            StatWidget(
                title: "Pending",
                value: "\(pendingSettlements)",
                color: Color.theme.sparkOrange
            )
        }
        .padding(.vertical, 12)
        .liquidGlass(intensity: 0.2, cornerRadius: 16)
        .padding(.horizontal)
    }
}

struct StatWidget: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(Color.theme.pureWhite.opacity(0.6))

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .refractiveText()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SessionDashboardView()
        .environmentObject(SessionManager())
}