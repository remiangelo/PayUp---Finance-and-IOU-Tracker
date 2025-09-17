import SwiftUI

struct LaunchScreenView: View {
    @State private var animateEdges = false
    @State private var showLogo = false
    @State private var pulseEffect = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Animated edge effects
            GeometryReader { geometry in
                // Top edge animation
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.75, blue: 1).opacity(0.8),
                                Color(red: 0, green: 0.5, blue: 1).opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 150)
                    .offset(y: animateEdges ? 0 : -150)
                    .blur(radius: animateEdges ? 20 : 5)
                    .animation(.easeOut(duration: 0.6), value: animateEdges)

                // Bottom edge animation
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.75, blue: 1).opacity(0.8),
                                Color(red: 0, green: 0.5, blue: 1).opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 150)
                    .offset(y: geometry.size.height - 150)
                    .offset(y: animateEdges ? 0 : 150)
                    .blur(radius: animateEdges ? 20 : 5)
                    .animation(.easeOut(duration: 0.6), value: animateEdges)

                // Left edge animation
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.75, blue: 1).opacity(0.8),
                                Color(red: 0, green: 0.5, blue: 1).opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 100)
                    .offset(x: animateEdges ? 0 : -100)
                    .blur(radius: animateEdges ? 20 : 5)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateEdges)

                // Right edge animation
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.75, blue: 1).opacity(0.8),
                                Color(red: 0, green: 0.5, blue: 1).opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                    .frame(width: 100)
                    .offset(x: geometry.size.width - 100)
                    .offset(x: animateEdges ? 0 : 100)
                    .blur(radius: animateEdges ? 20 : 5)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateEdges)
            }

            // Center content
            VStack(spacing: 20) {
                // App logo/icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0, green: 0.75, blue: 1),
                                    Color(red: 0, green: 0.5, blue: 1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: pulseEffect ? 30 : 10)
                        .scaleEffect(pulseEffect ? 1.3 : 1.0)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true),
                            value: pulseEffect
                        )

                    Image(systemName: "creditcard.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white,
                                    Color(red: 0, green: 0.75, blue: 1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(showLogo ? 1 : 0.3)
                        .opacity(showLogo ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLogo)
                }

                // App name
                Text("PayUp")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white,
                                Color(red: 0, green: 0.75, blue: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(showLogo ? 1 : 0.8)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showLogo)

                // Tagline
                Text("Track IOUs with friends")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .scaleEffect(showLogo ? 1 : 0.9)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: showLogo)
            }

            // Corner accent decorations
            VStack {
                HStack {
                    // Top left corner
                    CornerAccent()
                        .scaleEffect(animateEdges ? 1 : 0)
                        .opacity(animateEdges ? 0.6 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: animateEdges)

                    Spacer()

                    // Top right corner
                    CornerAccent()
                        .rotationEffect(.degrees(90))
                        .scaleEffect(animateEdges ? 1 : 0)
                        .opacity(animateEdges ? 0.6 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3), value: animateEdges)
                }

                Spacer()

                HStack {
                    // Bottom left corner
                    CornerAccent()
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(animateEdges ? 1 : 0)
                        .opacity(animateEdges ? 0.6 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.4), value: animateEdges)

                    Spacer()

                    // Bottom right corner
                    CornerAccent()
                        .rotationEffect(.degrees(180))
                        .scaleEffect(animateEdges ? 1 : 0)
                        .opacity(animateEdges ? 0.6 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.5), value: animateEdges)
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                animateEdges = true
                showLogo = true
                pulseEffect = true
            }

            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct CornerAccent: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 50))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 50, y: 0))
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0, green: 0.75, blue: 1),
                        Color(red: 0, green: 0.5, blue: 1).opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 50, height: 50)
            .blur(radius: 1)
        }
    }
}

#Preview {
    LaunchScreenView()
}