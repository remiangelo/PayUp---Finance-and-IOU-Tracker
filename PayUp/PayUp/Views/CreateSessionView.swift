import SwiftUI

struct CreateSessionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var sessionName = ""
    @State private var userName = ""
    @State private var appearAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Session Name")
                                .font(.caption)
                                .foregroundColor(Color.theme.brightCyan)
                                .padding(.horizontal, 4)

                            TextField("Friday Night Out", text: $sessionName, prompt: Text("Friday Night Out").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                                .glassTextField()
                                .autocapitalization(.words)
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

                    Text("A unique session key will be generated")
                        .font(.caption)
                        .foregroundColor(Color.theme.brightCyan.opacity(0.7))
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)

                    Spacer()

                    Button(action: {
                        sessionManager.createSession(name: sessionName, userName: userName)
                        dismiss()
                    }) {
                        Text("Create Session")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(width: 220, height: 54)
                            .glassCard(cornerRadius: 27)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: Color.theme.brightCyan.opacity(0.3), radius: 15, y: 5)
                    }
                    .disabled(sessionName.isEmpty || userName.isEmpty)
                    .opacity(sessionName.isEmpty || userName.isEmpty ? 0.5 : 1)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearAnimation)

                    Spacer()
                }
            }
            .navigationTitle("Create Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brightCyan)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
            }
        }
    }
}

#Preview {
    CreateSessionView()
        .environmentObject(SessionManager())
}
