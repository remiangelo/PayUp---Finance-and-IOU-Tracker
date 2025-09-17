import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var animateList = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if sessionManager.currentSession?.transactions.isEmpty ?? true {
                    EmptyTransactionState()
                        .padding(.top, 100)
                } else {
                    ForEach(Array(sessionManager.currentSession!.transactions.reversed().enumerated()), id: \.element.id) { index, transaction in
                        TransactionCard(transaction: transaction)
                            .opacity(animateList ? 1 : 0)
                            .offset(y: animateList ? 0 : 20)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                                value: animateList
                            )
                    }
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .onAppear {
            animateList = true
        }
        .onChange(of: sessionManager.currentSession?.transactions.count ?? 0) { _, _ in
            animateList = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateList = true
            }
        }
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isExpanded = false
    @State private var shimmerPhase: CGFloat = -1

    var payer: User? {
        sessionManager.currentSession?.users.first { $0.id == transaction.payerId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main card with liquid glass effect
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

                // Animated shimmer overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.clear, location: 0),
                                .init(color: Color.white.opacity(0.05), location: shimmerPhase),
                                .init(color: Color.clear, location: min(1, shimmerPhase + 0.1))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.description)
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption2)
                                    .foregroundColor(Color(red: 0, green: 0.75, blue: 1))
                                Text("Paid by \(payer?.name ?? "Unknown")")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "$%.2f", transaction.amount))
                                .font(.title3.bold())
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0, green: 0.75, blue: 1),
                                            Color(red: 0, green: 0.5, blue: 1)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text(formatDate(transaction.timestamp))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // Quick split info
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.caption)
                            .foregroundColor(Color(red: 0, green: 0.75, blue: 1).opacity(0.7))

                        Text("Split: $\(String(format: "%.2f", transaction.splitAmount)) × \(transaction.beneficiaryIds.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0, green: 0.75, blue: 1).opacity(0.8))
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 28, height: 28)
                                )
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    shimmerPhase = 2
                }
            }

            // Expandable beneficiaries section
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(transaction.beneficiaryIds, id: \.self) { userId in
                        if let user = sessionManager.currentSession?.users.first(where: { $0.id == userId }) {
                            HStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0, green: 0.75, blue: 1).opacity(0.5),
                                                Color(red: 0, green: 0.5, blue: 1).opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .fill(Color(red: 0, green: 0.75, blue: 1))
                                            .frame(width: 8, height: 8)
                                            .blur(radius: 3)
                                            .opacity(0.5)
                                    )

                                Text(user.name)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))

                                Spacer()

                                Text(String(format: "$%.2f", transaction.splitAmount))
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundColor(Color(red: 0, green: 0.75, blue: 1))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, -8)
                .padding(.bottom, 12)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyTransactionState: View {
    @State private var pulseAnimation = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Animated background circles
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0, green: 0.75, blue: 1).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                    .opacity(pulseAnimation ? 0 : 0.6)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0, green: 0.75, blue: 1),
                                        Color(red: 0, green: 0.5, blue: 1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .rotationEffect(.degrees(rotationAngle))
                            .blur(radius: 2)
                    )

                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white,
                                Color(red: 0, green: 0.75, blue: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("No Transactions Yet")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text("Add your first transaction to get started")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }

            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        TransactionsListView()
    }
    .environmentObject(SessionManager())
    .preferredColorScheme(.dark)
}