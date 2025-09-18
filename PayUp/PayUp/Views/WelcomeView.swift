import SwiftUI

struct WelcomeView: View {
    @Binding var showingCreateSession: Bool
    @Binding var showingJoinSession: Bool
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            // Professional background
            ProfessionalBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo and title
                VStack(spacing: ProfessionalDesignSystem.Spacing.lg) {
                    // Simple icon with subtle styling
                    ZStack {
                        Circle()
                            .fill(ProfessionalDesignSystem.Colors.cardBackground)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .stroke(ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.2),
                                   radius: 20, x: 0, y: 10)

                        Image(systemName: "creditcard.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(ProfessionalDesignSystem.Colors.primaryBlue)
                    }
                    .scaleEffect(appearAnimation ? 1 : 0.8)
                    .opacity(appearAnimation ? 1 : 0)

                    // App title
                    Text("PayUp")
                        .font(ProfessionalDesignSystem.Typography.largeTitle)
                        .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
                        .opacity(appearAnimation ? 1 : 0)

                    // Subtitle
                    Text("Simple IOU tracking for groups")
                        .font(ProfessionalDesignSystem.Typography.callout)
                        .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)
                        .opacity(appearAnimation ? 1 : 0)
                }
                .padding(.bottom, ProfessionalDesignSystem.Spacing.xxl)

                // Action buttons
                VStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                    PrimaryButton("Create New Session", icon: "plus.circle") {
                        showingCreateSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)

                    SecondaryButton("Join Existing Session", icon: "arrow.right.circle") {
                        showingJoinSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)
                }
                .padding(.horizontal, ProfessionalDesignSystem.Spacing.lg)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, ProfessionalDesignSystem.Spacing.lg)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
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