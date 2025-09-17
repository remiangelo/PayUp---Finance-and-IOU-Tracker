import SwiftUI

struct JoinSessionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var sessionKey = ""
    @State private var userName = ""
    @State private var showingError = false
    @State private var appearAnimation = false
    @State private var showingLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Session Key")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)
                                .padding(.horizontal, 4)

                            TextField("ABC123", text: $sessionKey, prompt: Text("ABC123").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                                .autocapitalization(.allCharacters)
                                .onChange(of: sessionKey) { _, newValue in
                                    sessionKey = String(newValue.uppercased().prefix(6))
                                }
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Name")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)
                                .padding(.horizontal, 4)

                            TextField("Enter your name", text: $userName, prompt: Text("Enter your name").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                                .autocapitalization(.words)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)
                    }
                    .padding(.horizontal, 30)

                    Text("Enter the 6-character code from your friend")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan.opacity(0.7))
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)

                    Spacer()

                    Button(action: {
                        sessionManager.joinSession(sessionKey: sessionKey, userName: userName)
                        if sessionManager.errorMessage != nil {
                            showingError = true
                        } else {
                            dismiss()
                        }
                    }) {
                        Text("Join Session")
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
                    .disabled(sessionKey.count != 6 || userName.isEmpty)
                    .opacity(sessionKey.count != 6 || userName.isEmpty ? 0.5 : 1)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearAnimation)

                    Spacer()
                }
            }
            .navigationTitle("Join Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brightCyan)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log In") {
                        showingLogin = true
                    }
                    .foregroundColor(Color.theme.brightCyan)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingLogin) {
                LoginView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    sessionManager.errorMessage = nil
                }
            } message: {
                Text(sessionManager.errorMessage ?? "Unknown error")
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
            }
        }
    }
}

#Preview {
    JoinSessionView()
        .environmentObject(SessionManager())
}
