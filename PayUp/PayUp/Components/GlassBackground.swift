import SwiftUI

struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.theme.darkNavy,
                    Color.theme.electricBlue.opacity(0.3),
                    Color.theme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { geometry in
                ForEach(0..<3) { index in
                    BlobShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    index % 2 == 0 ? Color.theme.brightCyan.opacity(0.3) : Color.theme.sparkOrange.opacity(0.3),
                                    index % 2 == 0 ? Color.theme.electricBlue.opacity(0.2) : Color.theme.danger.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(
                            x: CGFloat.random(in: -100...geometry.size.width),
                            y: CGFloat.random(in: -100...geometry.size.height)
                        )
                        .blur(radius: 30)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 15...30))
                                .repeatForever(autoreverses: true),
                            value: index
                        )
                }
            }
        }
    }
}

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        path.move(to: CGPoint(x: 0.9923 * width, y: 0.42593 * height))
        path.addCurve(
            to: CGPoint(x: 0.6355 * width, y: height),
            control1: CGPoint(x: 0.92554 * width, y: 0.77749 * height),
            control2: CGPoint(x: 0.91864 * width, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0.08995 * width, y: 0.60171 * height),
            control1: CGPoint(x: 0.35237 * width, y: height),
            control2: CGPoint(x: 0.2695 * width, y: 0.77304 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.34086 * width, y: 0.06324 * height),
            control1: CGPoint(x: -0.0896 * width, y: 0.43038 * height),
            control2: CGPoint(x: 0.00248 * width, y: 0.23012 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.9923 * width, y: 0.42593 * height),
            control1: CGPoint(x: 0.67924 * width, y: -0.10364 * height),
            control2: CGPoint(x: 1.05906 * width, y: 0.07436 * height)
        )
        path.closeSubpath()

        return path
    }
}

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.theme.surface.opacity(0.8))
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.02)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.theme.brightCyan.opacity(0.3),
                                            Color.theme.electricBlue.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    func glassTextField() -> some View {
        self
            .textFieldStyle(.plain)
            .padding()
            .readableGlassCard(cornerRadius: 12)
            .foregroundStyle(Color.theme.pureWhite)
            .tint(Color.theme.brightCyan)
            .accentColor(Color.theme.brightCyan)
    }
}

struct FloatingBubble: View {
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.2),
                        color.opacity(0.05)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 2)
            .offset(offset)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -30...30)
                    )
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}