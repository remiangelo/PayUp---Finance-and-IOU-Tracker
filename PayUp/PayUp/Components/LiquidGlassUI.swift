import SwiftUI
import Foundation

// MARK: - Liquid Glass UI Design System
// Premium glass morphism with liquid animations and depth effects

struct LiquidGlassUI {

    // MARK: - Color Palette
    struct Colors {
        // Base colors
        static let deepOcean = Color(red: 0, green: 0.05, blue: 0.08)
        static let midnightBlue = Color(red: 0, green: 0.11, blue: 0.24)
        static let darkPurple = Color(red: 0.18, green: 0.05, blue: 0.31)

        // Glass tints
        static let cyanGlass = Color(red: 0, green: 0.71, blue: 0.85)
        static let blueGlass = Color(red: 0, green: 0.47, blue: 0.71)
        static let purpleGlass = Color(red: 0.45, green: 0.04, blue: 0.72)

        // Glow colors
        static let neonCyan = Color(red: 0, green: 0.94, blue: 1.0)
        static let neonBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
        static let neonPurple = Color(red: 0.6, green: 0.2, blue: 1.0)

        // Functional colors
        static let success = Color(red: 0.2, green: 1.0, blue: 0.5)
        static let danger = Color(red: 1.0, green: 0.3, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)

        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.85)
        static let textTertiary = Color.white.opacity(0.6)

        // UI Elements
        static let divider = Color.white.opacity(0.15)
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 36, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 12, weight: .regular, design: .rounded)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 40
    }

    // MARK: - Glass Properties
    struct Glass {
        static let ultraThinBlur: CGFloat = 2
        static let thinBlur: CGFloat = 8
        static let regularBlur: CGFloat = 15
        static let thickBlur: CGFloat = 25
        static let ultraThickBlur: CGFloat = 40

        static let lightOpacity: Double = 0.15
        static let mediumOpacity: Double = 0.25
        static let heavyOpacity: Double = 0.35
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    @State private var animateGradient = false
    @State private var liquidPhase1: CGFloat = 0
    @State private var liquidPhase2: CGFloat = 0
    @State private var liquidPhase3: CGFloat = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient with multiple layers for depth
            ZStack {
                LinearGradient(
                    colors: [
                        LiquidGlassUI.Colors.deepOcean,
                        LiquidGlassUI.Colors.midnightBlue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        LiquidGlassUI.Colors.darkPurple.opacity(0.6),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 100,
                    endRadius: 400
                )

                RadialGradient(
                    colors: [
                        LiquidGlassUI.Colors.midnightBlue.opacity(0.5),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 100,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()

            // Liquid layers
            ForEach(0..<3) { index in
                LiquidLayer(
                    phase: index == 0 ? liquidPhase1 : index == 1 ? liquidPhase2 : liquidPhase3,
                    amplitude: 50 + CGFloat(index * 20),
                    frequency: 2.0 - Double(index) * 0.3,
                    opacity: 0.15 - Double(index) * 0.03,
                    gradientColors: index == 0 ?
                        [LiquidGlassUI.Colors.cyanGlass, LiquidGlassUI.Colors.blueGlass] :
                        index == 1 ?
                        [LiquidGlassUI.Colors.blueGlass, LiquidGlassUI.Colors.purpleGlass] :
                        [LiquidGlassUI.Colors.purpleGlass, LiquidGlassUI.Colors.cyanGlass]
                )
            }

            // Floating particles
            FloatingParticles()
                .opacity(0.6)

            // Ambient glow spots
            ForEach(0..<2) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                index == 0 ? LiquidGlassUI.Colors.neonCyan.opacity(0.15) : LiquidGlassUI.Colors.neonPurple.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(
                        x: index == 0 ? -100 : 100,
                        y: index == 0 ? -200 : 200
                    )
                    .blur(radius: 50)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                liquidPhase1 = .pi * 2
            }
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                liquidPhase2 = .pi * 2
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                liquidPhase3 = .pi * 2
            }
        }
    }
}

// MARK: - Liquid Layer Shape
struct LiquidLayer: View {
    let phase: CGFloat
    let amplitude: CGFloat
    let frequency: Double
    let opacity: Double
    let gradientColors: [Color]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height * 0.6

                path.move(to: CGPoint(x: 0, y: midHeight))

                for x in stride(from: 0, through: width, by: 2) {
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
                    colors: gradientColors.map { $0.opacity(opacity) },
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 10)
        }
    }
}

// MARK: - Premium Glass Card
struct PremiumGlassCard<Content: View>: View {
    let content: Content
    var glassIntensity: Double = 0.25
    var cornerRadius: CGFloat = 24
    var glowColor: Color = LiquidGlassUI.Colors.neonCyan
    var showGlow: Bool = true

    @State private var shimmerPhase: CGFloat = -1
    @State private var isHovered = false

    init(
        glassIntensity: Double = 0.25,
        cornerRadius: CGFloat = 24,
        glowColor: Color = LiquidGlassUI.Colors.neonCyan,
        showGlow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.glassIntensity = glassIntensity
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.showGlow = showGlow
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background glass layers
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(LiquidGlassUI.Colors.deepOcean.opacity(glassIntensity))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    LiquidGlassUI.Colors.cyanGlass.opacity(0.1),
                                    LiquidGlassUI.Colors.purpleGlass.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Shimmer effect
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.clear, location: max(0, shimmerPhase - 0.1)),
                            .init(color: Color.white.opacity(0.15), location: shimmerPhase),
                            .init(color: Color.clear, location: min(1, shimmerPhase + 0.1))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .allowsHitTesting(false)

            // Border gradient
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // Content
            content
                .padding(LiquidGlassUI.Spacing.lg)
        }
        .shadow(color: showGlow ? glowColor.opacity(0.3) : Color.clear, radius: isHovered ? 20 : 10)
        .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.5
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Liquid Button
struct LiquidButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .primary

    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    @State private var liquidFill: CGFloat = 0

    enum ButtonStyle {
        case primary
        case secondary
        case danger
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return LiquidGlassUI.Colors.cyanGlass
            case .secondary: return LiquidGlassUI.Colors.blueGlass
            case .danger: return LiquidGlassUI.Colors.danger
            case .success: return LiquidGlassUI.Colors.success
            }
        }

        var glowColor: Color {
            switch self {
            case .primary: return LiquidGlassUI.Colors.neonCyan
            case .secondary: return LiquidGlassUI.Colors.neonBlue
            case .danger: return LiquidGlassUI.Colors.danger
            case .success: return LiquidGlassUI.Colors.success
            }
        }
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            // Trigger ripple effect
            withAnimation(.easeOut(duration: 0.6)) {
                rippleScale = 2
                rippleOpacity = 0
            }

            // Liquid fill animation
            withAnimation(.spring(response: 0.3)) {
                liquidFill = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.2)) {
                    liquidFill = 0
                }
                rippleScale = 0
                rippleOpacity = 0.5
            }

            action()
        }) {
            ZStack {
                // Background glass
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .fill(style.backgroundColor.opacity(0.3))
                    )

                // Liquid fill effect
                GeometryReader { geometry in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    style.backgroundColor.opacity(0.6),
                                    style.backgroundColor.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * liquidFill)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: liquidFill)
                }

                // Ripple effect
                Circle()
                    .fill(style.glowColor.opacity(rippleOpacity))
                    .scaleEffect(rippleScale)

                // Border
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                style.glowColor.opacity(0.6),
                                style.glowColor.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                // Content
                HStack(spacing: LiquidGlassUI.Spacing.sm) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(LiquidGlassUI.Typography.callout)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, LiquidGlassUI.Spacing.lg)
                .padding(.vertical, LiquidGlassUI.Spacing.md)
            }
            .frame(height: 48)
        }
        .buttonStyle(LiquidButtonStyle())
        .shadow(color: style.glowColor.opacity(0.4), radius: isPressed ? 5 : 10)
        .onTapGesture {} // Capture tap for ripple
    }
}

// MARK: - Liquid Button Style
struct LiquidButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    @FocusState private var isFocused: Bool
    @State private var glowIntensity: Double = 0

    var body: some View {
        ZStack(alignment: .leading) {
            // Background glass
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    LiquidGlassUI.Colors.neonCyan.opacity(isFocused ? 0.6 : 0.2),
                                    LiquidGlassUI.Colors.neonBlue.opacity(isFocused ? 0.4 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: isFocused ? LiquidGlassUI.Colors.neonCyan.opacity(0.3) : Color.clear, radius: 10)

            // Placeholder
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .font(LiquidGlassUI.Typography.body)
                    .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                    .padding(.horizontal, LiquidGlassUI.Spacing.md)
            }

            // Text field
            if isSecure {
                SecureField("", text: $text)
                    .font(LiquidGlassUI.Typography.body)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                    .padding(.horizontal, LiquidGlassUI.Spacing.md)
                    .focused($isFocused)
            } else {
                TextField("", text: $text)
                    .font(LiquidGlassUI.Typography.body)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                    .padding(.horizontal, LiquidGlassUI.Spacing.md)
                    .focused($isFocused)
            }
        }
        .frame(height: 52)
        .animation(.spring(response: 0.3), value: isFocused)
    }
}

// MARK: - Floating Particles
struct FloatingParticles: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var color: Color
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                        .blur(radius: 2)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles()
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<20).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.7),
                color: [LiquidGlassUI.Colors.neonCyan, LiquidGlassUI.Colors.neonBlue, LiquidGlassUI.Colors.neonPurple].randomElement()!
            )
        }
    }

    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                particles = particles.map { particle in
                    var p = particle
                    p.y -= CGFloat.random(in: 0.5...2)
                    if p.y < -10 {
                        p.y = 800 // Default height
                        p.x = CGFloat.random(in: 0...400) // Default width
                    }
                    return p
                }
            }
        }
    }
}

// MARK: - Glass Tab Bar (iOS 26 Style)
struct GlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var liquidPosition: CGFloat = 0
    @Namespace private var tabAnimation

    var body: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(tabs.count)

            ZStack {
                // Background glass with iOS 26 liquid style
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )

                // Liquid indicator background
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            LiquidGlassUI.Colors.neonCyan.opacity(0.2),
                                            LiquidGlassUI.Colors.neonBlue.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    LiquidGlassUI.Colors.neonCyan.opacity(0.4),
                                                    LiquidGlassUI.Colors.neonBlue.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                                .frame(width: tabWidth - 12, height: 48)
                                .matchedGeometryEffect(id: "liquidTab", in: tabAnimation)
                        } else {
                            Color.clear
                                .frame(width: tabWidth - 12, height: 48)
                        }
                    }
                }
                .padding(.horizontal, 6)

                // Tab items
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        TabItem(
                            icon: tabs[index].icon,
                            label: tabs[index].label,
                            isSelected: selectedTab == index,
                            action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedTab = index
                                }
                            }
                        )
                        .frame(width: tabWidth)
                    }
                }
            }
        }
        .frame(height: 68)
        .shadow(color: Color.black.opacity(0.2), radius: 8, y: -2)
    }

    struct TabItem: View {
        let icon: String
        let label: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .medium : .regular))
                        .foregroundColor(isSelected ? LiquidGlassUI.Colors.neonCyan : LiquidGlassUI.Colors.textTertiary.opacity(0.7))
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                    Text(label)
                        .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? LiquidGlassUI.Colors.neonCyan : LiquidGlassUI.Colors.textTertiary.opacity(0.6))
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Liquid Glass Navigation Bar (iOS 26 Apple Music Style)
struct LiquidGlassNavigationBar: View {
    let title: String
    var leftAction: (() -> Void)?
    var leftIcon: String?
    var leftText: String?
    var rightAction: (() -> Void)?
    var rightIcon: String?
    var rightText: String?

    @State private var liquidAnimation: CGFloat = 0

    var body: some View {
        ZStack {
            // Ultra-thin liquid glass layers (iOS 26 Apple Music)
            ZStack {
                // Base blur layer - ultra thin
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Additional glass depth
                Rectangle()
                    .fill(.thinMaterial.opacity(0.2))

                // Liquid glass gradient
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.08), location: 0),
                        .init(color: Color.white.opacity(0.03), location: 0.3),
                        .init(color: Color.clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Dark overlay for depth
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )

                // Liquid animation (very subtle)
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height

                        path.move(to: CGPoint(x: 0, y: height - 0.5))

                        for x in stride(from: 0, through: width, by: 10) {
                            let relativeX = x / width
                            let y = height - 0.5 + sin(relativeX * .pi * 4 + liquidAnimation) * 0.5
                            path.addLine(to: CGPoint(x: x, y: y))
                        }

                        path.addLine(to: CGPoint(x: width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.02),
                                Color.white.opacity(0.01)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }

                // Bottom separator
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.33)
                }
            }

            // Navigation content with proper alignment
            VStack(spacing: 0) {
                // Status bar spacer
                Color.clear
                    .frame(height: 47) // iOS status bar height

                // Navigation bar content
                ZStack {
                    // Title in center
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Left and right buttons
                    HStack {
                        // Left button
                        if let leftAction = leftAction {
                            Button(action: leftAction) {
                                HStack(spacing: 3) {
                                    if let leftIcon = leftIcon {
                                        Image(systemName: leftIcon)
                                            .font(.system(size: 17, weight: .regular))
                                    }
                                    if let leftText = leftText {
                                        Text(leftText)
                                            .font(.system(size: 17, weight: .regular))
                                    }
                                }
                                .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()

                        // Right button
                        if let rightAction = rightAction {
                            Button(action: rightAction) {
                                HStack(spacing: 3) {
                                    if let rightText = rightText {
                                        Text(rightText)
                                            .font(.system(size: 17, weight: .regular))
                                    }
                                    if let rightIcon = rightIcon {
                                        Image(systemName: rightIcon)
                                            .font(.system(size: 17, weight: .regular))
                                    }
                                }
                                .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 44) // Standard iOS nav bar height
            }
        }
        .frame(height: 91) // Total height (47 status + 44 nav)
        .onAppear {
            // Very subtle liquid animation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                liquidAnimation = .pi * 2
            }
        }
    }
}

// MARK: - Liquid Loading Indicator
struct LiquidLoader: View {
    @State private var rotation: Double = 0
    @State private var liquidPhase: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            LiquidGlassUI.Colors.neonCyan,
                            LiquidGlassUI.Colors.neonBlue,
                            LiquidGlassUI.Colors.neonPurple,
                            LiquidGlassUI.Colors.neonCyan
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .rotationEffect(.degrees(rotation))
                .blur(radius: 3)

            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    LiquidGlassUI.Colors.neonCyan.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                )
        }
        .frame(width: 60, height: 60)
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}