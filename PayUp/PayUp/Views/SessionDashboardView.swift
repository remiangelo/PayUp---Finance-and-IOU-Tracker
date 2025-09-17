import SwiftUI

struct SessionDashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass background
                LiquidBackground()

                VStack(spacing: 0) {
                    // Header info card
                    if let session = sessionManager.currentSession {
                        LiquidGlassCard(materialType: .ultraThin, cornerRadius: 24) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Session Code")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(session.sessionKey)
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Participants")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("\(session.users.count)")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
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
                    .padding(.top, 10)

                    // Custom tab bar
                    HStack(spacing: 0) {
                        TabBarButton(icon: "list.bullet", label: "Transactions", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }

                        TabBarButton(icon: "chart.pie.fill", label: "Balances", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }

                        TabBarButton(icon: "arrow.left.arrow.right", label: "Settle", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }

                        TabBarButton(icon: "info.circle", label: "Info", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 20, y: -5)
                    )
                }

                // Floating add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingGlassButton(icon: "plus", action: {
                            showingAddTransaction = true
                        })
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(sessionManager.currentSession?.name ?? "Session")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(sessionManager)
            }
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0, green: 0.75, blue: 1) : .white.opacity(0.6))

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0, green: 0.75, blue: 1) : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(red: 0, green: 0.75, blue: 1).opacity(0.1) : Color.clear)
            )
            .overlay(
                isSelected ?
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0, green: 0.75, blue: 1).opacity(0.3), lineWidth: 1)
                    .blur(radius: 2)
                : nil
            )
        }
    }
}

#Preview {
    SessionDashboardView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}