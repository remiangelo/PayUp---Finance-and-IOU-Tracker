import SwiftUI

struct SessionDashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                TabView(selection: $selectedTab) {
                    TransactionsListView()
                        .tabItem {
                            Label("Transactions", systemImage: "list.bullet")
                        }
                        .tag(0)

                    BalancesView()
                        .tabItem {
                            Label("Balances", systemImage: "chart.pie.fill")
                        }
                        .tag(1)

                    SettlementsView()
                        .tabItem {
                            Label("Settle Up", systemImage: "arrow.left.arrow.right")
                        }
                        .tag(2)

                    SessionInfoView()
                        .tabItem {
                            Label("Session", systemImage: "person.3.fill")
                        }
                        .tag(3)
                }
            }
            .navigationTitle(sessionManager.currentSession?.name ?? "Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
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
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(sessionManager)
            }
        }
    }
}

#Preview {
    SessionDashboardView()
        .environmentObject(SessionManager())
}