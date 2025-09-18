import SwiftUI

// MARK: - Professional Design System
// Clean, minimal design with subtle depth and professional appearance

struct ProfessionalDesignSystem {

    // MARK: - Color Palette
    struct Colors {
        static let primaryBlue = Color(red: 0.2, green: 0.5, blue: 1.0)
        static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
        static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)
        static let success = Color.green
        static let danger = Color(red: 1.0, green: 0.4, blue: 0.3)
        static let divider = Color.white.opacity(0.1)
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
}

// MARK: - Simple Background
struct ProfessionalBackground: View {
    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    ProfessionalDesignSystem.Colors.darkBackground,
                    ProfessionalDesignSystem.Colors.darkBackground.opacity(0.95),
                    Color(red: 0.1, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Very subtle mesh gradient overlay
            GeometryReader { geometry in
                Canvas { context, size in
                    // Add subtle circular gradients for depth
                    let topGradient = Gradient(colors: [
                        ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.05),
                        Color.clear
                    ])
                    context.fill(
                        Path(ellipseIn: CGRect(x: -size.width * 0.5, y: -size.height * 0.3,
                                               width: size.width * 1.5, height: size.height)),
                        with: .radialGradient(topGradient, center: .zero, startRadius: 0, endRadius: size.width)
                    )

                    let bottomGradient = Gradient(colors: [
                        ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.03),
                        Color.clear
                    ])
                    context.fill(
                        Path(ellipseIn: CGRect(x: size.width * 0.3, y: size.height * 0.5,
                                               width: size.width, height: size.height * 0.8)),
                        with: .radialGradient(bottomGradient, center: .zero, startRadius: 0, endRadius: size.width * 0.7)
                    )
                }
                .blur(radius: 60)
            }
        }
    }
}

// MARK: - Simple Card Component
struct ProfessionalCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = ProfessionalDesignSystem.Spacing.md

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ProfessionalDesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ProfessionalDesignSystem.Colors.divider, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDestructive: Bool = false

    init(_ title: String, icon: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfessionalDesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(ProfessionalDesignSystem.Typography.callout)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, ProfessionalDesignSystem.Spacing.lg)
            .padding(.vertical, ProfessionalDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDestructive ? ProfessionalDesignSystem.Colors.danger : ProfessionalDesignSystem.Colors.primaryBlue)
            )
            .shadow(color: (isDestructive ? ProfessionalDesignSystem.Colors.danger : ProfessionalDesignSystem.Colors.primaryBlue).opacity(0.3),
                   radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfessionalDesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .regular))
                }
                Text(title)
                    .font(ProfessionalDesignSystem.Typography.callout)
            }
            .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)
            .padding(.horizontal, ProfessionalDesignSystem.Spacing.lg)
            .padding(.vertical, ProfessionalDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ProfessionalDesignSystem.Colors.divider, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ProfessionalDesignSystem.Colors.cardBackground.opacity(0.5))
                    )
            )
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Simple Tab Bar
struct ProfessionalTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabButton(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, ProfessionalDesignSystem.Spacing.xs)
        .padding(.vertical, ProfessionalDesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ProfessionalDesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ProfessionalDesignSystem.Colors.divider, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: -2)
    }

    private struct TabButton: View {
        let icon: String
        let label: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? ProfessionalDesignSystem.Colors.primaryBlue : ProfessionalDesignSystem.Colors.textTertiary)

                    Text(label)
                        .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                        .foregroundColor(isSelected ? ProfessionalDesignSystem.Colors.primaryBlue : ProfessionalDesignSystem.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ProfessionalDesignSystem.Spacing.sm)
                .background(
                    isSelected ?
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.1))
                    : nil
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(ProfessionalDesignSystem.Colors.primaryBlue)
                )
                .shadow(color: ProfessionalDesignSystem.Colors.primaryBlue.opacity(0.4),
                       radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = ProfessionalDesignSystem.Colors.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .font(ProfessionalDesignSystem.Typography.body)
                .foregroundColor(ProfessionalDesignSystem.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(ProfessionalDesignSystem.Typography.body)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(ProfessionalDesignSystem.Typography.headline)
                .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(ProfessionalDesignSystem.Typography.caption)
                    .foregroundColor(ProfessionalDesignSystem.Colors.textTertiary)
            }
        }
    }
}

// MARK: - Pressed Button Style
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct ProfessionalDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ProfessionalBackground()

            VStack(spacing: ProfessionalDesignSystem.Spacing.lg) {
                Text("PayUp")
                    .font(ProfessionalDesignSystem.Typography.largeTitle)
                    .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

                ProfessionalCard {
                    VStack(alignment: .leading, spacing: ProfessionalDesignSystem.Spacing.md) {
                        SectionHeader("Session Balance", subtitle: "3 participants")

                        Text("$125.50")
                            .font(ProfessionalDesignSystem.Typography.title)
                            .foregroundColor(ProfessionalDesignSystem.Colors.textPrimary)

                        Divider()
                            .background(ProfessionalDesignSystem.Colors.divider)

                        InfoRow(label: "You owe", value: "$42.50", valueColor: ProfessionalDesignSystem.Colors.danger)
                        InfoRow(label: "Others owe you", value: "$18.00", valueColor: ProfessionalDesignSystem.Colors.success)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: ProfessionalDesignSystem.Spacing.md) {
                    PrimaryButton("Add Transaction", icon: "plus") {}
                    SecondaryButton("Settle", icon: "checkmark") {}
                }

                Spacer()

                ProfessionalTabBar(
                    selectedTab: .constant(0),
                    tabs: [
                        ("list.bullet", "Transactions"),
                        ("chart.pie.fill", "Balances"),
                        ("arrow.left.arrow.right", "Settle"),
                        ("info.circle", "Info")
                    ]
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top, 60)
        }
        .preferredColorScheme(.dark)
    }
}