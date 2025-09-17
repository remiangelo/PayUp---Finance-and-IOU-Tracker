import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isAnimating: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)
                                .padding(.horizontal, 4)

                            TextField("name@example.com", text: $email, prompt: Text("name@example.com").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .glassTextField()
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)
                                .padding(.horizontal, 4)

                            SecureField("Enter your password", text: $password, prompt: Text("Enter your password").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Button(action: {
                        // Non-functional: just dismiss for now
                        dismiss()
                    }) {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(width: 220, height: 54)
                            .glassCard(cornerRadius: 27)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.theme.brightCyan.opacity(0.5), lineWidth: 1.5)
                            )
                            .foregroundColor(.white)
                            .shadow(color: Color.theme.brightCyan.opacity(0.2), radius: 10, y: 3)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimating)

                    Button {
                        // Placeholder for password reset
                    } label: {
                        Text("Forgot password?")
                            .font(.footnote)
                            .foregroundColor(Color.theme.brightCyan.opacity(0.8))
                    }
                    .padding(.top, 8)

                    Spacer()
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.theme.brightCyan)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
