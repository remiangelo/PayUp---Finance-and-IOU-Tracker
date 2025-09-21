import SwiftUI

struct SessionDashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0
    @State private var appearAnimation = false
    @State private var glowAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass background
                LiquidGlassBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom liquid glass navigation bar (iOS 26 Apple Music style)
                    LiquidGlassNavigationBar(
                        title: sessionManager.currentSession?.name ?? "Session",
                        leftAction: {
                            sessionManager.leaveSession()
                        },
                        leftIcon: "chevron.left",
                        leftText: "Leave"
                    )
                    .ignoresSafeArea(edges: .top)

                    // Session info header with compact design
                    if let session = sessionManager.currentSession {
                        HStack(spacing: LiquidGlassUI.Spacing.lg) {
                            // Session code
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SESSION")
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(1.2)
                                    .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                                Text(session.sessionKey)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                LiquidGlassUI.Colors.neonCyan,
                                                LiquidGlassUI.Colors.neonBlue
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }

                            Spacer()

                            // Participants
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(LiquidGlassUI.Colors.neonCyan.opacity(0.8))

                                Text("\(session.users.count)")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(LiquidGlassUI.Colors.neonCyan.opacity(0.3), lineWidth: 0.5)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    // Tab content with glass background
                    TabView(selection: $selectedTab) {
                        TransactionsListView()
                            .tag(0)

                        BalancesView()
                            .tag(1)

                        SettlementsView()
                            .tag(2)

                        SessionInfoView()
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.top, LiquidGlassUI.Spacing.md)

                    // Custom liquid glass tab bar
                    GlassTabBar(
                        selectedTab: $selectedTab,
                        tabs: [
                            ("list.bullet.rectangle.fill", "Activity"),
                            ("chart.pie.fill", "Balances"),
                            ("arrow.left.arrow.right.circle.fill", "Settle"),
                            ("info.circle.fill", "Info")
                        ]
                    )
                    .padding(.horizontal)
                    .padding(.bottom, LiquidGlassUI.Spacing.lg)
                }

                // Floating action button with liquid effect
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            LiquidGlassUI.Colors.neonCyan.opacity(0.4),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 40
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: 10)
                                .scaleEffect(glowAnimation ? 1.3 : 1.0)

                            Button(action: {
                                showingAddTransaction = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            LiquidGlassUI.Colors.neonCyan.opacity(0.4),
                                                            LiquidGlassUI.Colors.neonBlue.opacity(0.3)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            LiquidGlassUI.Colors.neonCyan,
                                                            LiquidGlassUI.Colors.neonBlue
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                                .blur(radius: 1)
                                        )

                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(glowAnimation ? 90 : 0))
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.6), radius: 15)
                        }
                        .padding(.trailing, LiquidGlassUI.Spacing.lg)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(sessionManager)
                    .background(LiquidGlassBackground())
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    SessionDashboardView()
        .environmentObject(SessionManager())
        .preferredColorScheme(.dark)
}