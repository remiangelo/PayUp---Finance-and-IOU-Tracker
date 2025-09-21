import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isAnimating: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                ProfessionalBackground()

                VStack(spacing: LiquidGlassUI.Spacing.xl) {
                    Spacer()

                    // Title
                    Text("Sign In")
                        .font(LiquidGlassUI.Typography.title)
                        .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                        .opacity(isAnimating ? 1 : 0)

                    // Form fields
                    VStack(spacing: LiquidGlassUI.Spacing.lg) {
                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.sm) {
                            Text("Email")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)

                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .textFieldStyle(ProfessionalTextFieldStyle())
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.sm) {
                            Text("Password")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textSecondary)

                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(ProfessionalTextFieldStyle())
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: isAnimating)
                    }
                    .padding(.horizontal, LiquidGlassUI.Spacing.xl)

                    Spacer()

                    // Action buttons
                    VStack(spacing: LiquidGlassUI.Spacing.md) {
                        PrimaryButton("Sign In") {
                            // Non-functional: just dismiss for now
                            dismiss()
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: isAnimating)

                        Button {
                            // Placeholder for password reset
                        } label: {
                            Text("Forgot password?")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.neonBlue)
                        }
                        .padding(.top, LiquidGlassUI.Spacing.sm)
                    }
                    .padding(.horizontal, LiquidGlassUI.Spacing.xl)
                    .padding(.bottom, LiquidGlassUI.Spacing.xl)
                }
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Text Field Style
struct ProfessionalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(LiquidGlassUI.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassUI.Colors.deepOcean.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LiquidGlassUI.Colors.divider, lineWidth: 0.5)
                    )
            )
            .foregroundColor(LiquidGlassUI.Colors.textPrimary)
            .font(LiquidGlassUI.Typography.body)
    }
}

#Preview {
    LoginView()
}
