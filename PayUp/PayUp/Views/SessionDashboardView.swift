import SwiftUI

struct SessionDashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Professional background
                ProfessionalBackground()

                VStack(spacing: 0) {
                    // Session info header
                    if let session = sessionManager.currentSession {
                        ProfessionalCard {
                            HStack {
                                VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.xs) {
                                    Text("Session Code")
                                        .font(ProfessionalDesignSystem.Typography.caption)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                                    Text(session.sessionKey)
                                        .font(ProfessionalDesignSystem.Typography.headline)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: ProfessionalDesignSystem.Spacing.xs) {
                                    Text("Participants")
                                        .font(ProfessionalDesignSystem.Typography.caption)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                                    Text("\(session.users.count)")
                                        .font(ProfessionalDesignSystem.Typography.headline)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, ProfessionalDesignSystem.Spacing.sm)
                    }

                    // Tab content
                    TabView(selection: $selectedTab) {
                        TransactionsListView()
                            .tag(0)

                        BalancesView()
                            .tag(1)

                        SettlementsView()
                            .tag(2)

                        SessionInfoView()
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.top, ProfessionalDesignSystem.Spacing.sm)

                    // Custom tab bar
                    ProfessionalTabBar(
                        selectedTab: $selectedTab,
                        tabs: [
                            ("list.bullet", "Transactions"),
                            ("chart.pie.fill", "Balances"),
                            ("arrow.left.arrow.right", "Settle"),
                            ("info.circle", "Info")
                        ]
                    )
                    .padding(.horizontal)
                    .padding(.bottom, ProfessionalDesignSystem.Spacing.lg)
                }

                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "plus", action: {
                            showingAddTransaction = true
                        })
                        .padding(.trailing, ProfessionalDesignSystem.Spacing.lg)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(sessionManager.currentSession?.name ?? "Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        sessionManager.leaveSession()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Leave")
                        }
                        .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(sessionManager)
                    .background(ProfessionalBackground())
            }
        }
    }
}

#Preview {
    SessionDashboardView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}