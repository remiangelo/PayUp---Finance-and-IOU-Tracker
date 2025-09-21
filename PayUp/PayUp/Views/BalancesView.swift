import SwiftUI

struct BalancesView: View {
    @EnvironmentObject var sessionManager: SessionManager

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

    private var totalPositive: Double {
        balances.filter { $0.balance > 0 }.reduce(0) { $0 + $1.balance }
    }

    private var totalNegative: Double {
        abs(balances.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                // Summary Card
                if !balances.isEmpty {
                    ProfessionalCard {
                        VStack(spacing: LiquidGlassUI.Spacing.md) {
                            Text("Balance Summary")
                                .font(LiquidGlassUI.Typography.headline)
                                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                            HStack(spacing: LiquidGlassUI.Spacing.xl) {
                                VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                                    Text("To Receive")
                                        .font(LiquidGlassUI.Typography.caption)
                                        .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                                    Text(String(format: "$%.2f", totalPositive))
                                        .font(LiquidGlassUI.Typography.title)
                                        .foregroundColor(LiquidGlassUI.Colors.success)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: LiquidGlassUI.Spacing.xs) {
                                    Text("To Pay")
                                        .font(LiquidGlassUI.Typography.caption)
                                        .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                                    Text(String(format: "$%.2f", totalNegative))
                                        .font(LiquidGlassUI.Typography.title)
                                        .foregroundColor(LiquidGlassUI.Colors.danger)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Individual Balances
                VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                    if !balances.isEmpty {
                        Text("Individual Balances")
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                            .padding(.horizontal)
                    }

                    if balances.isEmpty {
                        EmptyBalanceState()
                            .padding(.top, 100)
                    } else {
                        ForEach(balances, id: \.user.id) { item in
                            BalanceRow(
                                user: item.user,
                                balance: item.balance,
                                isCurrentUser: item.user.id == sessionManager.currentUser?.id
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, LiquidGlassUI.Spacing.sm)
            }
            .padding(.top, LiquidGlassUI.Spacing.md)
            .padding(.bottom, 120) // Space for tab bar
        }
        .background(Color.clear)
    }
}

struct BalanceRow: View {
    let user: User
    let balance: Double
    let isCurrentUser: Bool

    private var balanceColor: Color {
        if balance > 0.01 {
            return LiquidGlassUI.Colors.success
        } else if balance < -0.01 {
            return LiquidGlassUI.Colors.danger
        } else {
            return LiquidGlassUI.Colors.textSecondary
        }
    }

    private var statusText: String {
        if abs(balance) < 0.01 {
            return "Settled"
        } else if balance > 0 {
            return "is owed"
        } else {
            return "owes"
        }
    }

    var body: some View {
        ProfessionalCard {
            HStack {
                // User info
                HStack(spacing: LiquidGlassUI.Spacing.sm) {
                    Circle()
                        .fill(LiquidGlassUI.Colors.neonBlue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(user.name.prefix(1).uppercased()))
                                .font(LiquidGlassUI.Typography.headline)
                                .foregroundColor(LiquidGlassUI.Colors.neonBlue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(user.name)
                                .font(LiquidGlassUI.Typography.body)
                                .fontWeight(.medium)
                                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                            if isCurrentUser {
                                Text("(You)")
                                    .font(LiquidGlassUI.Typography.caption)
                                    .foregroundColor(LiquidGlassUI.Colors.neonBlue)
                            }
                        }

                        Text(statusText)
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                    }
                }

                Spacer()

                // Balance amount
                Text(String(format: "$%.2f", abs(balance)))
                    .font(LiquidGlassUI.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(balanceColor)
            }
        }
    }
}

struct EmptyBalanceState: View {
    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.md) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

            Text("No balances yet")
                .font(LiquidGlassUI.Typography.headline)
                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

            Text("Balances will appear once transactions are added")
                .font(LiquidGlassUI.Typography.body)
                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LiquidGlassUI.Spacing.xl)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        ProfessionalBackground()
        BalancesView()
    }
    .environmentObject(SessionManager())
    .preferredColorScheme(.dark)
}