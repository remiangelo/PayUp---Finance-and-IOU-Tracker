import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var animateCards = false

    var transactions: [Transaction] {
        sessionManager.currentSession?.transactions ?? []
    }

    var users: [User] {
        sessionManager.currentSession?.users ?? []
    }

    func userName(for id: UUID) -> String {
        users.first { $0.id == id }?.name ?? "Unknown"
    }

    var body: some View {
        ZStack {
            WallpaperBackground()

            ScrollView {
                if transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("No Transactions")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Add your first transaction to get started")
                            .foregroundColor(Color.theme.brightCyan)
                    }
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(Array(transactions.reversed().enumerated()), id: \.element.id) { index, transaction in
                            TransactionCard(
                                transaction: transaction,
                                payerName: userName(for: transaction.payerId),
                                index: index
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                value: animateCards
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    let payerName: String
    let index: Int
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 5) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                        Text("\(payerName) paid")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color.theme.brightCyan)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", transaction.amount))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.success, Color.theme.brightCyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("÷\(transaction.beneficiaryIds.count)")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan.opacity(0.8))
                }
            }

            HStack {
                Label(
                    "Split: $\(String(format: "%.2f", transaction.splitAmount)) each",
                    systemImage: "arrow.triangle.branch"
                )
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))

                Spacer()

                Text(transaction.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.5))
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

#Preview {
    TransactionsListView()
        .environmentObject(SessionManager())
}