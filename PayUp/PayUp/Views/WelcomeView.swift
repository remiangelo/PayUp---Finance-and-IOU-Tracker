import SwiftUI

struct WelcomeView: View {
    @Binding var showingCreateSession: Bool
    @Binding var showingJoinSession: Bool
    @State private var appearAnimation = false
    @State private var buttonHover = false

    var body: some View {
        ZStack {
            WallpaperBackground()

            VStack(spacing: 60) {
                Spacer()

                // Clean logo with subtle animation
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(appearAnimation ? 1.0 : 0.5)
                        .opacity(appearAnimation ? 1.0 : 0.0)

                    Text("PayUp")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.pureWhite)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                        .offset(y: appearAnimation ? 0 : 20)
                }

                // Simplified button stack
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateSession = true
                    }) {
                        Text("Create Session")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(width: 220, height: 54)
                            .glassCard(cornerRadius: 27)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: Color.theme.brightCyan.opacity(0.3), radius: 15, y: 5)
                    }
                    .opacity(appearAnimation ? 1.0 : 0.0)
                    .offset(y: appearAnimation ? 0 : 30)

                    Button(action: {
                        showingJoinSession = true
                    }) {
                        Text("Join Session")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(width: 220, height: 54)
                            .glassCard(cornerRadius: 27)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.theme.brightCyan.opacity(0.5), lineWidth: 1.5)
                            )
                            .foregroundColor(Color.theme.pureWhite)
                            .shadow(color: Color.theme.brightCyan.opacity(0.2), radius: 10, y: 3)
                    }
                    .opacity(appearAnimation ? 1.0 : 0.0)
                    .offset(y: appearAnimation ? 0 : 30)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
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
}