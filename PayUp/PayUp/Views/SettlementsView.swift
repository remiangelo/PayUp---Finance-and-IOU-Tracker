import SwiftUI

struct SettlementsView: View {
    @EnvironmentObject var sessionManager: SessionManager

    private var settlements: [(from: User, to: User, amount: Double)] {
        sessionManager.currentSession?.getSettlements() ?? []
    }

    private var totalToSettle: Double {
        settlements.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: ProfessionalDesignSystem.Spacing.lg) {
                // Header Card
                if !settlements.isEmpty {
                    ProfessionalCard {
                        VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(ProfessionalDesignSystem.Colors.success)

                                Text("Settlements Ready")
                                    .font(ProfessionalDesignSystem.Typography.headline)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                            }

                            Text("\(settlements.count) payment\(settlements.count == 1 ? "" : "s") to settle all debts")
                                .font(ProfessionalDesignSystem.Typography.body)
                                .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                }

                // Settlements List
                if settlements.isEmpty {
                    EmptySettlementsState()
                        .padding(.top, 100)
                } else {
                    VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                        ForEach(Array(settlements.enumerated()), id: \.offset) { _, settlement in
                            SettlementCard(
                                from: settlement.from,
                                to: settlement.to,
                                amount: settlement.amount
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, ProfessionalDesignSystem.Spacing.sm)
                }
            }
            .padding(.top, ProfessionalDesignSystem.Spacing.md)
            .padding(.bottom, 120) // Space for tab bar
        }
        .background(Color.clear)
    }
}

struct SettlementCard: View {
    let from: User
    let to: User
    let amount: Double
    @State private var isMarkedAsPaid = false

    var body: some View {
        ProfessionalCard {
            VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.md) {
                // Payment direction
                HStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                    // From user
                    VStack(alignment: .center, spacing: ProfessionalDesignSystem.Spacing.xs) {
                        Circle()
                            .fill(ProfessionalDesignSystem.Colors.danger.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(from.name.prefix(1).uppercased()))
                                    .font(ProfessionalDesignSystem.Typography.headline)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.danger)
                            )

                        Text(from.name)
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)

                    // Arrow with amount
                    VStack(spacing: ProfessionalDesignSystem.Spacing.xs) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)

                        Text(String(format: "$%.2f", amount))
                            .font(ProfessionalDesignSystem.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                    }

                    // To user
                    VStack(alignment: .center, spacing: ProfessionalDesignSystem.Spacing.xs) {
                        Circle()
                            .fill(ProfessionalDesignSystem.Colors.success.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(to.name.prefix(1).uppercased()))
                                    .font(ProfessionalDesignSystem.Typography.headline)
                                    .foregroundColor(ProfessionalDesignSystem.Colors.success)
                            )

                        Text(to.name)
                            .font(ProfessionalDesignSystem.Typography.caption)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Mark as paid button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMarkedAsPaid.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isMarkedAsPaid ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isMarkedAsPaid ? ProfessionalDesignSystem.Colors.success : ProfessionalDesignSystem.Colors.textTertiary)

                        Text(isMarkedAsPaid ? "Marked as paid" : "Mark as paid")
                            .font(ProfessionalDesignSystem.Typography.callout)
                            .foregroundColor(isMarkedAsPaid ? ProfessionalDesignSystem.Colors.success : ProfessionalDesignSystem.Colors.textSecondary)

                        Spacer()
                    }
                    .padding(ProfessionalDesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isMarkedAsPaid ? ProfessionalDesignSystem.Colors.success.opacity(0.1) : ProfessionalDesignSystem.Colors.cardBackground.opacity(0.5))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .opacity(isMarkedAsPaid ? 0.7 : 1.0)
    }
}

struct EmptySettlementsState: View {
    var body: some View {
        VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundColor(ProfessionalDesignSystem.Colors.success)

            Text("All settled up!")
                .font(ProfessionalDesignSystem.Typography.headline)
                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

            Text("No payments needed at this time")
                .font(ProfessionalDesignSystem.Typography.body)
                .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        ProfessionalBackground()
        SettlementsView()
    }
    .environmentObject(SessionManager())
    .preferredColorScheme(.dark)
}