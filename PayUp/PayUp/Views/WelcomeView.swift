import SwiftUI

struct WelcomeView: View {
    @Binding var showingCreateSession: Bool
    @Binding var showingJoinSession: Bool
    @State private var appearAnimation = false
    @State private var orbRotation: Double = 0
    @State private var liquidPhase: CGFloat = 0
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Liquid glass background
            LiquidGlassBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo and title section
                VStack(spacing: LiquidGlassUI.Spacing.xl) {
                    // Animated glass orb logo
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                        LiquidGlassUI.Colors.neonBlue.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 20)
                            .scaleEffect(glowPulse ? 1.2 : 0.9)

                        // Glass orb with liquid inside
                        ZStack {
                            // Base glass sphere
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    LiquidGlassUI.Colors.cyanGlass.opacity(0.3),
                                                    LiquidGlassUI.Colors.purpleGlass.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )

                            // Internal liquid animation
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [
                                            LiquidGlassUI.Colors.neonCyan,
                                            LiquidGlassUI.Colors.neonBlue,
                                            LiquidGlassUI.Colors.neonPurple,
                                            LiquidGlassUI.Colors.neonCyan
                                        ],
                                        center: .center,
                                        angle: .degrees(orbRotation)
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 15)
                                .opacity(0.6)

                            // Glass refraction border
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 140, height: 140)
                                .blur(radius: 0.5)

                            // Center icon
                            Image(systemName: "creditcard.circle.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            LiquidGlassUI.Colors.textPrimary,
                                            LiquidGlassUI.Colors.neonCyan
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: LiquidGlassUI.Colors.neonCyan, radius: 10)
                        }
                        .rotationEffect(.degrees(orbRotation * 0.1))
                    }
                    .scaleEffect(appearAnimation ? 1 : 0.5)
                    .opacity(appearAnimation ? 1 : 0)

                    // App title with glass effect
                    VStack(spacing: LiquidGlassUI.Spacing.sm) {
                        Text("PayUp")
                            .font(LiquidGlassUI.Typography.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        LiquidGlassUI.Colors.textPrimary,
                                        LiquidGlassUI.Colors.neonCyan,
                                        LiquidGlassUI.Colors.neonBlue
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.5), radius: 15)

                        Text("Split expenses with liquid ease")
                            .font(LiquidGlassUI.Typography.callout)
                            .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                }
                .padding(.bottom, LiquidGlassUI.Spacing.xxl * 1.5)

                // Action buttons section
                VStack(spacing: LiquidGlassUI.Spacing.lg) {
                    LiquidButton("Create New Session", icon: "plus.circle.fill", style: .primary) {
                        showingCreateSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)

                    LiquidButton("Join Existing Session", icon: "arrow.right.circle.fill", style: .secondary) {
                        showingJoinSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 40)
                }
                .padding(.horizontal, LiquidGlassUI.Spacing.xl)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appearAnimation = true
            }

            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                orbRotation = 360
            }

            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

#Preview {
    WelcomeView(
        showingCreateSession: .constant(false),
        showingJoinSession: .constant(false)
    )
    .preferredColorScheme(.dark)
}