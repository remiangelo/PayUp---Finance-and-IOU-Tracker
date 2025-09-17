import SwiftUI

struct SettlementsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var animateSettlements = false
    @State private var rotationAngles: [Double] = []

    var settlements: [(from: User, to: User, amount: Double)] {
        sessionManager.currentSession?.getSettlements() ?? []
    }

    var body: some View {
        ZStack {
            WallpaperBackground()

            ScrollView {
                VStack(spacing: 20) {
                    if settlements.isEmpty {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.theme.brightCyan.opacity(0.3),
                                                Color.theme.electricBlue.opacity(0.1)
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .blur(radius: 20)

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color.theme.electricBlue.opacity(0.3), radius: 10)
                            }

                            VStack(spacing: 10) {
                                Text("All Settled Up!")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )

                                Text("No outstanding debts")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Suggested Settlements")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.horizontal)

                            LazyVStack(spacing: 20) {
                                ForEach(Array(settlements.enumerated()), id: \.offset) { index, settlement in
                                    SettlementCard(
                                        settlement: settlement,
                                        isCurrentUser: settlement.from.id == sessionManager.currentUser?.id || settlement.to.id == sessionManager.currentUser?.id,
                                        currentUserId: sessionManager.currentUser?.id,
                                        index: index,
                                        rotationAngle: index < rotationAngles.count ? rotationAngles[index] : 0
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.7)
                                            .delay(Double(index) * 0.1),
                                        value: animateSettlements
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)

                        Text("These payments will settle all debts with minimum transactions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .glassCard(cornerRadius: 15)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            rotationAngles = settlements.map { _ in Double.random(in: -3...3) }
            animateSettlements = true
        }
    }
}

struct SettlementCard: View {
    let settlement: (from: User, to: User, amount: Double)
    let isCurrentUser: Bool
    let currentUserId: UUID?
    let index: Int
    let rotationAngle: Double
    @State private var showArrowAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                UserBubble(
                    user: settlement.from,
                    color: Color.theme.danger,
                    isDebtor: true
                )

                VStack(spacing: 10) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.theme.electricBlue.opacity(0.3), radius: 5)
                        .offset(x: showArrowAnimation ? 10 : -10)

                    Text("$\(String(format: "%.2f", settlement.amount))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                UserBubble(
                    user: settlement.to,
                    color: Color.theme.brightCyan,
                    isDebtor: false
                )
            }

            if isCurrentUser {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.theme.electricBlue.opacity(0.7))
                    Text(settlement.from.id == currentUserId
                         ? "You owe \(settlement.to.name)"
                         : "\(settlement.from.name) owes you")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    Color.theme.darkNavy.opacity(0.3)
                )
                .cornerRadius(12)
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: isCurrentUser
                            ? [Color.theme.brightCyan.opacity(0.5), Color.theme.electricBlue.opacity(0.3)]
                            : [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isCurrentUser ? 2 : 1
                )
        )
        .shadow(
            color: isCurrentUser
                ? Color.theme.electricBlue.opacity(0.2)
                : Color.black.opacity(0.1),
            radius: 15,
            x: 0,
            y: 8
        )
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showArrowAnimation = true
            }
        }
    }
}

struct UserBubble: View {
    let user: User
    let color: Color
    let isDebtor: Bool
    @State private var showPulse = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(showPulse ? 1.15 : 1.0)
                    .opacity(showPulse ? 0.5 : 1.0)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.3), radius: 5)
            }

            Text(user.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(Double.random(in: 0...0.5))) {
                showPulse = true
            }
        }
    }
}

#Preview {
    SettlementsView()
        .environmentObject(SessionManager())
}