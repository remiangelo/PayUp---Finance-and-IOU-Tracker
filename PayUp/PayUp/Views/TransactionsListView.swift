import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ScrollView {
            VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                if sessionManager.currentSession?.transactions.isEmpty ?? true {
                    EmptyTransactionState()
                        .padding(.top, 100)
                } else {
                    ForEach(sessionManager.currentSession?.transactions.sorted(by: { $0.createdAt > $1.createdAt }) ?? []) { transaction in
                        TransactionCard(transaction: transaction)
                            .padding(.horizontal)
                    }
                    .padding(.top, ProfessionalDesignSystem.Spacing.md)
                }
            }
            .padding(.bottom, 120) // Space for tab bar and FAB
        }
        .background(Color.clear)
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isExpanded = false

    private var payerName: String {
        sessionManager.currentSession?.users.first(where: { $0.id == transaction.payerId })?.name ?? "Unknown"
    }

    private var beneficiaryNames: [String] {
        transaction.beneficiaryIds.compactMap { id in
            sessionManager.currentSession?.users.first(where: { $0.id == id })?.name
        }
    }

    private var amountPerPerson: Double {
        guard !transaction.beneficiaryIds.isEmpty else { return 0 }
        return transaction.amount / Double(transaction.beneficiaryIds.count)
    }

    var body: some View {
        ProfessionalCard {
            VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.xs) {
                        Text(transaction.description)
                            .font(ProfessionalDesignSystem.Typography.headline)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                            .lineLimit(1)

                        Text(payerName + " paid")
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: ProfessionalDesignSystem.Spacing.xs) {
                        Text(String(format: "$%.2f", transaction.amount))
                            .font(ProfessionalDesignSystem.Typography.headline)
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)

                        Text(transaction.createdAt, style: .time)
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
                    }
                }

                // Expandable details
                if isExpanded {
                    Divider()
                        .background(ProfessionalDesignSystem.Colors.divider)

                    VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.sm) {
                        Text("Split between:")
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)

                        ForEach(beneficiaryNames, id: \.self) { name in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)

                                Text(name)
                                    .font(ProfessionalDesignSystem.Typography.body)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

                                Spacer()

                                Text(String(format: "$%.2f", amountPerPerson))
                                    .font(ProfessionalDesignSystem.Typography.callout)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                }

                // Expand/Collapse button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Show less" : "Show details")
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct EmptyTransactionState: View {
    var body: some View {
        VStack(spacing: ProfessionalDesignSystem.Spacing.lg) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)

            Text("No transactions yet")
                .font(ProfessionalDesignSystem.Typography.headline)
                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

            Text("Add your first transaction to get started")
                .font(ProfessionalDesignSystem.Typography.body)
                .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ProfessionalDesignSystem.Spacing.xl)
        }
    }
}

#Preview {
    ZStack {
        ProfessionalBackground()
        TransactionsListView()
    }
    .environmentObject(SessionManager())
    .preferredColorScheme(.dark)
}