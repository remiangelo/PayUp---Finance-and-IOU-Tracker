import SwiftUI

// MARK: - Liquid Glass Design System
// Following Apple's HIG for materials and visual effects

struct LiquidGlassDesignSystem {

    // MARK: - Material Types (iOS 17+)
    enum MaterialType {
        case ultraThin
        case thin
        case regular
        case thick
        case chrome

        var material: Material {
            switch self {
            case .ultraThin: return .ultraThinMaterial
            case .thin: return .thinMaterial
            case .regular: return .regularMaterial
            case .thick: return .thickMaterial
            case .chrome: return .ultraThickMaterial
            }
        }
    }
}

// MARK: - Advanced Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    var materialType: LiquidGlassDesignSystem.MaterialType = .regular
    var cornerRadius: CGFloat = 20
    @State private var ripplePhase: CGFloat = 0
    @State private var shimmerPosition: CGFloat = -1

    init(materialType: LiquidGlassDesignSystem.MaterialType = .regular,
         cornerRadius: CGFloat = 20,
         @ViewBuilder content: () -> Content) {
        self.materialType = materialType
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Base glass layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(materialType.material)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)

            // Liquid shimmer overlay
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.white.opacity(0.1), location: shimmerPosition),
                            .init(color: Color.clear, location: min(1, shimmerPosition + 0.1))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .allowsHitTesting(false)

            // Content
            content
                .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerPosition = 2
            }
        }
    }
}

// MARK: - Liquid Background
struct LiquidBackground: View {
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0, green: 0.1, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Flowing liquid layers
                ForEach(0..<3) { index in
                    LiquidWave(
                        phase: index == 0 ? phase1 : index == 1 ? phase2 : phase3,
                        amplitude: 30 + CGFloat(index * 10),
                        frequency: 1.5 - Double(index) * 0.3,
                        color: Color(red: 0, green: 0.5 + Double(index) * 0.25, blue: 1)
                            .opacity(0.3 - Double(index) * 0.08)
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    phase1 = .pi * 2
                }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    phase2 = .pi * 2
                }
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    phase3 = .pi * 2
                }
            }
        }
    }
}

// MARK: - Liquid Wave Shape
struct LiquidWave: View {
    let phase: CGFloat
    let amplitude: CGFloat
    let frequency: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height * 0.7

                path.move(to: CGPoint(x: 0, y: midHeight))

                for x in stride(from: 0, to: width, by: 1) {
                    let relativeX = x / width
                    let y = midHeight + sin(relativeX * .pi * frequency + phase) * amplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 5)
        }
    }
}

// MARK: - Frosted Glass Button
struct FrostedGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @State private var isPressed = false
    @State private var glowAnimation = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)

                    // Gradient overlay
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0, green: 0.75, blue: 1).opacity(0.3),
                                    Color(red: 0, green: 0.5, blue: 1).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Glow effect
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0, green: 0.75, blue: 1),
                                    Color(red: 0, green: 0.5, blue: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: glowAnimation ? 2 : 1
                        )
                        .blur(radius: glowAnimation ? 4 : 2)
                        .opacity(glowAnimation ? 0.8 : 0.4)
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color(red: 0, green: 0.75, blue: 1).opacity(0.3),
                radius: isPressed ? 5 : 10,
                x: 0,
                y: isPressed ? 2 : 5
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
}

// MARK: - Liquid Text Effect
struct LiquidText: View {
    let text: String
    let fontSize: CGFloat
    @State private var wavePhase: CGFloat = 0

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        .white,
                        Color(red: 0.5 + sin(wavePhase) * 0.5, green: 0.7, blue: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: Color(red: 0, green: 0.75, blue: 1).opacity(0.5), radius: 10)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    wavePhase = .pi * 2
                }
            }
    }
}

// MARK: - Floating Action Button
struct FloatingGlassButton: View {
    let icon: String
    let action: () -> Void
    @State private var isFloating = false
    @State private var ripple = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Ripple effect
                Circle()
                    .fill(Color(red: 0, green: 0.75, blue: 1))
                    .frame(width: 56, height: 56)
                    .scaleEffect(ripple ? 2 : 0)
                    .opacity(ripple ? 0 : 0.5)

                // Button
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
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
                            .blur(radius: 2)
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(
                        color: Color(red: 0, green: 0.75, blue: 1).opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: isFloating ? 8 : 5
                    )
                    .offset(y: isFloating ? -5 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isFloating = true
            }

            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                ripple = true
            }
        }
    }
}

// MARK: - Preview
struct LiquidGlassDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LiquidBackground()

            VStack(spacing: 20) {
                LiquidText(text: "PayUp", fontSize: 48)

                LiquidGlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Balance")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("$125.50")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                HStack(spacing: 16) {
                    FrostedGlassButton("Add Transaction", icon: "plus.circle") {}
                    FrostedGlassButton("Settle", icon: "checkmark.circle") {}
                }

                Spacer()

                FloatingGlassButton(icon: "plus", action: {})
                    .padding(.bottom, 30)
            }
            .padding(.top, 60)
        }
        .preferredColorScheme(.dark)
    }
}