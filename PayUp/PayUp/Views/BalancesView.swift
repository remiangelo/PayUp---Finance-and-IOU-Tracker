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
            VStack(spacing: ProfessionalDesignSystem.Spacing.lg) {
                // Summary Card
                if !balances.isEmpty {
                    ProfessionalCard {
                        VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                            Text("Balance Summary")
                                .font(ProfessionalDesignSystem.Typography.headline)
                                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

                            HStack(spacing: ProfessionalDesignSystem.Spacing.xl) {
                                VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.xs) {
                                    Text("To Receive")
                                        .font(ProfessionalDesignSystem.Typography.caption)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                                    Text(String(format: "$%.2f", totalPositive))
                                        .font(ProfessionalDesignSystem.Typography.title)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.success)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: ProfessionalDesignSystem.Spacing.xs) {
                                    Text("To Pay")
                                        .font(ProfessionalDesignSystem.Typography.caption)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                                    Text(String(format: "$%.2f", totalNegative))
                                        .font(ProfessionalDesignSystem.Typography.title)
                                        .foregroundColor(ProfessionalDesignSystem.Colors.danger)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Individual Balances
                VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.md) {
                    if !balances.isEmpty {
                        Text("Individual Balances")
                            .font(ProfessionalDesignSystem.Typography.headline)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
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
                .padding(.top, ProfessionalDesignSystem.Spacing.sm)
            }
            .padding(.top, ProfessionalDesignSystem.Spacing.md)
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
            return ProfessionalDesignSystem.Colors.success
        } else if balance < -0.01 {
            return ProfessionalDesignSystem.Colors.danger
        } else {
            return ProfessionalDesignSystem.Colors.textSecondary
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
                HStack(spacing: ProfessionalDesignSystem.Spacing.sm) {
                    Circle()
                        .fill(ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(user.name.prefix(1).uppercased()))
                                .font(ProfessionalDesignSystem.Typography.headline)
                                .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(user.name)
                                .font(ProfessionalDesignSystem.Typography.body)
                                .fontWeight(.medium)
                                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

                            if isCurrentUser {
                                Text("(You)")
                                    .font(ProfessionalDesignSystem.Typography.caption)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                            }
                        }

                        Text(statusText)
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                    }
                }

                Spacer()

                // Balance amount
                Text(String(format: "$%.2f", abs(balance)))
                    .font(ProfessionalDesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(balanceColor)
            }
        }
    }
}

struct EmptyBalanceState: View {
    var body: some View {
        VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)

            Text("No balances yet")
                .font(ProfessionalDesignSystem.Typography.headline)
                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

            Text("Balances will appear once transactions are added")
                .font(ProfessionalDesignSystem.Typography.body)
                .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ProfessionalDesignSystem.Spacing.xl)
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