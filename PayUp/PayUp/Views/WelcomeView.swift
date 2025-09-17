import SwiftUI

struct WelcomeView: View {
    @Binding var showingCreateSession: Bool
    @Binding var showingJoinSession: Bool
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            // Liquid glass background
            LiquidBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo and title
                VStack(spacing: 24) {
                    // Animated glass orb with icon
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0, green: 0.75, blue: 1).opacity(0.6),
                                                Color(red: 0, green: 0.5, blue: 1).opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .blur(radius: 3)
                            )
                            .shadow(
                                color: Color(red: 0, green: 0.75, blue: 1).opacity(0.4),
                                radius: 20,
                                x: 0,
                                y: 10
                            )

                        Image(systemName: "creditcard.circle.fill")
                            .font(.system(size: 60))
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
                    .scaleEffect(appearAnimation ? 1 : 0.5)
                    .opacity(appearAnimation ? 1 : 0)

                    // App title
                    LiquidText(text: "PayUp", fontSize: 48)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)

                    // Subtitle
                    Text("Track IOUs with style")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                }
                .padding(.bottom, 60)

                // Action buttons
                VStack(spacing: 20) {
                    FrostedGlassButton("Create New Session", icon: "plus.circle.fill") {
                        showingCreateSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)

                    FrostedGlassButton("Join Existing Session", icon: "arrow.right.circle.fill") {
                        showingJoinSession = true
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 40)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 20)
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
    .preferredColorScheme(.dark)
}