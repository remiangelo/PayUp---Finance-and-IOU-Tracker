import SwiftUI

struct WallpaperBackground: View {
    var body: some View {
        ZStack {
            // Dark background base
            Color.theme.background
                .ignoresSafeArea()

            // Simulated wallpaper effect with gradients
            GeometryReader { geometry in
                ZStack {
                    // Main flowing liquid effect
                    ForEach(0..<3) { index in
                        WaveShape(phase: Double(index) * 0.5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.theme.brightCyan.opacity(0.3),
                                        Color.theme.electricBlue.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 20)
                            .offset(y: CGFloat(index) * 100)
                    }

                    // Sparkle effects
                    ForEach(0..<15) { _ in
                        Circle()
                            .fill(Color.theme.sparkOrange)
                            .frame(width: CGFloat.random(in: 2...4))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .blur(radius: 0.5)
                            .opacity(Double.random(in: 0.3...0.8))
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct WaveShape: Shape {
    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let y = midHeight + sin(relativeX * .pi * 3 + phase) * height * 0.3
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

// Enhanced glass card for better readability
struct ReadableGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Dark base for readability
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.theme.surface.opacity(0.9))

                    // Glass overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.theme.glassBg,
                                    Color.theme.glassBg.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.theme.glassStroke,
                                    Color.theme.glassStroke.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.theme.shadowColor, radius: 15, x: 0, y: 10)
    }
}

extension View {
    func readableGlassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(ReadableGlassCard(cornerRadius: cornerRadius))
    }
}