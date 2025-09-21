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
            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                // Header Card
                if !settlements.isEmpty {
                    ProfessionalCard {
                        VStack(spacing: LiquidGlassUI.Spacing.md) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(LiquidGlassUI.Colors.success)

                                Text("Settlements Ready")
                                    .font(LiquidGlassUI.Typography.headline)
                                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                            }

                            Text("\(settlements.count) payment\(settlements.count == 1 ? "" : "s") to settle all debts")
                                .font(LiquidGlassUI.Typography.body)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                }

                // Settlements List
                if settlements.isEmpty {
                    EmptySettlementsState()
                        .padding(.top, 100)
                } else {
                    VStack(spacing: LiquidGlassUI.Spacing.md) {
                        ForEach(Array(settlements.enumerated()), id: \.offset) { _, settlement in
                            SettlementCard(
                                from: settlement.from,
                                to: settlement.to,
                                amount: settlement.amount
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, LiquidGlassUI.Spacing.sm)
                }
            }
            .padding(.top, LiquidGlassUI.Spacing.md)
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
            VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                // Payment direction
                HStack(spacing: LiquidGlassUI.Spacing.md) {
                    // From user
                    VStack(alignment: .center, spacing: LiquidGlassUI.Spacing.xs) {
                        Circle()
                            .fill(LiquidGlassUI.Colors.danger.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(from.name.prefix(1).uppercased()))
                                    .font(LiquidGlassUI.Typography.headline)
                                    .foregroundColor(LiquidGlassUI.Colors.danger)
                            )

                        Text(from.name)
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)

                    // Arrow with amount
                    VStack(spacing: LiquidGlassUI.Spacing.xs) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(LiquidGlassUI.Colors.neonBlue)

                        Text(String(format: "$%.2f", amount))
                            .font(LiquidGlassUI.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(LiquidGlassUI.Colors.neonBlue)
                    }

                    // To user
                    VStack(alignment: .center, spacing: LiquidGlassUI.Spacing.xs) {
                        Circle()
                            .fill(LiquidGlassUI.Colors.success.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(to.name.prefix(1).uppercased()))
                                    .font(LiquidGlassUI.Typography.headline)
                                    .foregroundColor(LiquidGlassUI.Colors.success)
                            )

                        Text(to.name)
                            .font(LiquidGlassUI.Typography.caption)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
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
                            .foregroundColor(isMarkedAsPaid ? LiquidGlassUI.Colors.success : LiquidGlassUI.Colors.textTertiary)

                        Text(isMarkedAsPaid ? "Marked as paid" : "Mark as paid")
                            .font(LiquidGlassUI.Typography.callout)
                            .foregroundColor(isMarkedAsPaid ? LiquidGlassUI.Colors.success : LiquidGlassUI.Colors.textSecondary)

                        Spacer()
                    }
                    .padding(LiquidGlassUI.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isMarkedAsPaid ? LiquidGlassUI.Colors.success.opacity(0.1) : LiquidGlassUI.Colors.deepOcean.opacity(0.5))
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
        VStack(spacing: LiquidGlassUI.Spacing.md) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundColor(LiquidGlassUI.Colors.success)

            Text("All settled up!")
                .font(LiquidGlassUI.Typography.headline)
                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

            Text("No payments needed at this time")
                .font(LiquidGlassUI.Typography.body)
                .foregroundColor(LiquidGlassUI.Colors.textSecondary)
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