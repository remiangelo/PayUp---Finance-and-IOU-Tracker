import SwiftUI

struct BalancesView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var animateBalances = false

    var balances: [(user: User, balance: Double)] {
        guard let session = sessionManager.currentSession else { return [] }
        let balanceDict = session.calculateBalances()

        return session.users.compactMap { user in
            if let balance = balanceDict[user.id] {
                return (user, balance)
            }
            return nil
        }.sorted { abs($0.balance) > abs($1.balance) }
    }

    var body: some View {
        ZStack {
            WallpaperBackground()

            ScrollView {
                VStack(spacing: 20) {
                    if balances.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            Text("No Balances")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Add transactions to see balances")
                                .foregroundColor(Color.theme.brightCyan)
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(Array(balances.enumerated()), id: \.element.user.id) { index, item in
                                BalanceCard(
                                    user: item.user,
                                    balance: item.balance,
                                    isCurrentUser: item.user.id == sessionManager.currentUser?.id,
                                    index: index
                                )
                                .transition(.asymmetric(
                                    insertion: .slide.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.08),
                                    value: animateBalances
                                )
                            }
                        }
                        .padding()

                        SummaryCard(balances: balances)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            animateBalances = true
        }
    }
}

struct BalanceCard: View {
    let user: User
    let balance: Double
    let isCurrentUser: Bool
    let index: Int
    @State private var showPulse = false

    var balanceColor: Color {
        if balance > 0 {
            return Color.theme.success
        } else if balance < 0 {
            return Color.theme.danger
        } else {
            return Color.theme.brightCyan
        }
    }

    var statusText: String {
        if balance > 0 {
            return "is owed"
        } else if balance < 0 {
            return "owes"
        } else {
            return "settled up"
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                balanceColor.opacity(0.3),
                                balanceColor.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(showPulse ? 1.2 : 1.0)
                    .opacity(showPulse ? 0.5 : 1.0)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(balanceColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(Color.theme.brightCyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.theme.brightCyan.opacity(0.2))
                            .cornerRadius(8)
                    }
                }

                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.brightCyan.opacity(0.8))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", abs(balance)))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(balanceColor)

                if balance != 0 {
                    Image(systemName: balance > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.caption)
                        .foregroundColor(balanceColor.opacity(0.7))
                }
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(balanceColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            if abs(balance) > 0 {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    showPulse = true
                }
            }
        }
    }
}

struct SummaryCard: View {
    let balances: [(user: User, balance: Double)]

    var totalInPlay: Double {
        balances.filter { $0.balance > 0 }.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Total in Play")
                        .font(.headline)
                        .foregroundColor(Color.theme.brightCyan)

                    Text("$\(String(format: "%.2f", totalInPlay))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.success, Color.theme.brightCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.theme.brightCyan.opacity(0.3), radius: 10)
            }

            Text("This is the total amount being tracked in IOUs")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(25)
        .readableGlassCard(cornerRadius: 25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.theme.brightCyan.opacity(0.3), Color.theme.electricBlue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    BalancesView()
        .environmentObject(SessionManager())
}