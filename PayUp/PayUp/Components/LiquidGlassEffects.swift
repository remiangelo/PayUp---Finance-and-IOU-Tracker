import SwiftUI

// MARK: - Enhanced Glass Material System

struct LiquidGlassMaterial: ViewModifier {
    let intensity: Double
    let tint: Color
    let cornerRadius: CGFloat
    @State private var shimmerPhase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass layer with Material
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(tint.opacity(intensity * 0.1))
                        )

                    // Shimmer effect
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: max(0, shimmerPhase - 0.2)),
                                .init(color: .white, location: shimmerPhase),
                                .init(color: .clear, location: min(1, shimmerPhase + 0.2)),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(RoundedRectangle(cornerRadius: cornerRadius))
                    )
                    .opacity(0.8)

                    // Glass edge highlight
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    tint.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerPhase = 1.2
                }
            }
    }
}

// MARK: - Liquid Blur Effect

struct LiquidBlurView: View {
    let radius: CGFloat
    let opaque: Bool
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Create animated gradient effect without MeshGradient
                ForEach(0..<3, id: \.self) { index in
                    let gradientColors: [Color] = index == 0 ?
                        [Color.theme.darkNavy.opacity(0.8), Color.clear] :
                        index == 1 ?
                        [Color.theme.electricBlue.opacity(0.4), Color.clear] :
                        [Color.theme.brightCyan.opacity(0.3), Color.clear]

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: gradientColors,
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.5
                            )
                        )
                        .scaleEffect(1.0 + sin(animationPhase + Double(index)) * 0.2)
                        .offset(
                            x: cos(animationPhase + Double(index) * 2) * 50,
                            y: sin(animationPhase + Double(index) * 2) * 50
                        )
                        .blur(radius: radius, opaque: opaque)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    animationPhase = .pi * 2
                }
            }
        }
    }
}

// MARK: - Morphing Liquid Shape

struct LiquidShape: Shape {
    var animationProgress: CGFloat

    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Dynamic control points based on animation
        let cp1x = width * (0.35 + sin(animationProgress * 2) * 0.1)
        let cp1y = height * (0.2 + cos(animationProgress * 3) * 0.05)
        let cp2x = width * (0.65 + cos(animationProgress * 2.5) * 0.1)
        let cp2y = height * (0.8 + sin(animationProgress * 2) * 0.05)

        path.move(to: CGPoint(x: 0, y: height * 0.5))

        path.addCurve(
            to: CGPoint(x: width, y: height * 0.5),
            control1: CGPoint(x: cp1x, y: cp1y),
            control2: CGPoint(x: cp2x, y: cp2y)
        )

        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.5),
            control1: CGPoint(x: width - cp1x, y: height - cp1y),
            control2: CGPoint(x: width - cp2x, y: height - cp2y)
        )

        return path
    }
}

// MARK: - Interactive Glass Card

struct InteractiveGlassCard: ViewModifier {
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .liquidGlass(intensity: isPressed ? 0.8 : 0.5, cornerRadius: cornerRadius)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(dragOffset)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isPressed = true
                        dragOffset = CGSize(
                            width: value.translation.width * 0.5,
                            height: value.translation.height * 0.5
                        )
                    }
                    .onEnded { _ in
                        isPressed = false
                        dragOffset = .zero
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }
    }
}

// MARK: - Prismatic Effect

struct PrismaticEffect: ViewModifier {
    @State private var hueRotation: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                content
                    .blur(radius: 4)
                    .hueRotation(.degrees(hueRotation))
                    .blendMode(.hardLight)
                    .opacity(0.3)
            )
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    hueRotation = 360
                }
            }
    }
}

// MARK: - Liquid Animation Container

struct LiquidAnimationContainer<Content: View>: View {
    let content: () -> Content
    @State private var liquidPhase: CGFloat = 0

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            // Animated liquid background
            ForEach(0..<3, id: \.self) { index in
                LiquidShape(animationProgress: liquidPhase)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.brightCyan.opacity(0.3),
                                Color.theme.electricBlue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(Double(index) * 120))
                    .blur(radius: 20)
                    .scaleEffect(1.5)
                    .animation(
                        .easeInOut(duration: Double(8 + index * 2))
                        .repeatForever(autoreverses: true),
                        value: liquidPhase
                    )
            }

            content()
        }
        .onAppear {
            liquidPhase = 1
        }
    }
}

// MARK: - Depth Glass Layer

struct DepthGlassLayer: ViewModifier {
    let depth: Int
    let maxDepth: Int

    func body(content: Content) -> some View {
        content
            .background(
                ForEach(0..<depth, id: \.self) { layer in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(Double(maxDepth - layer) / Double(maxDepth))
                        .blur(radius: CGFloat(layer) * 0.5)
                        .offset(
                            x: CGFloat(layer) * 2,
                            y: CGFloat(layer) * 2
                        )
                }
            )
    }
}

// MARK: - Refractive Text Effect

struct RefractiveText: ViewModifier {
    @State private var gradientPhase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        .init(color: Color.theme.pureWhite, location: 0),
                        .init(color: Color.theme.brightCyan, location: gradientPhase - 0.2),
                        .init(color: Color.theme.electricBlue, location: gradientPhase),
                        .init(color: Color.theme.pureWhite, location: gradientPhase + 0.2),
                        .init(color: Color.theme.pureWhite, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    gradientPhase = 1.2
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlass(
        intensity: Double = 0.5,
        tint: Color = Color.theme.brightCyan,
        cornerRadius: CGFloat = 20
    ) -> some View {
        modifier(LiquidGlassMaterial(
            intensity: intensity,
            tint: tint,
            cornerRadius: cornerRadius
        ))
    }

    func interactiveGlass(cornerRadius: CGFloat = 20) -> some View {
        modifier(InteractiveGlassCard(cornerRadius: cornerRadius))
    }

    func prismaticEffect() -> some View {
        modifier(PrismaticEffect())
    }

    func depthGlass(depth: Int = 3, maxDepth: Int = 5) -> some View {
        modifier(DepthGlassLayer(depth: depth, maxDepth: maxDepth))
    }

    func refractiveText() -> some View {
        modifier(RefractiveText())
    }
}

// MARK: - Frosted Glass Tab Bar

struct FrostedGlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]

    struct TabItem {
        let icon: String
        let title: String
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 24))
                        Text(tabs[index].title)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTab == index ? Color.theme.brightCyan : Color.theme.pureWhite.opacity(0.7))
                    .background(
                        selectedTab == index ?
                        AnyView(
                            Capsule()
                                .fill(Color.theme.brightCyan.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.theme.brightCyan.opacity(0.3), lineWidth: 1)
                                )
                        ) : AnyView(Color.clear)
                    )
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}