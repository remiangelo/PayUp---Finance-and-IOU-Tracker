import SwiftUI

struct SessionInfoView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingShareSheet = false
    @State private var showingLeaveConfirmation = false
    @State private var animateCards = false

    var session: Session? {
        sessionManager.currentSession
    }

    var shareText: String {
        guard let session = session else { return "" }
        return "Join my PayUp session '\(session.name)'! Use code: \(session.sessionKey)"
    }

    var body: some View {
        ZStack {
            WallpaperBackground()

            ScrollView {
                if let session = session {
                    VStack(spacing: 20) {
                        // Session Details Card
                        SessionDetailsCard(session: session, showingShareSheet: $showingShareSheet)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateCards)

                        // Participants Card
                        ParticipantsCard(session: session, currentUserId: sessionManager.currentUser?.id)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateCards)

                        // Statistics Card
                        StatisticsCard(session: session)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateCards)

                        // Leave Session Button
                        Button(action: {
                            showingLeaveConfirmation = true
                        }) {
                            Label("Leave Session", systemImage: "arrow.right.square")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(width: 200, height: 50)
                                .glassCard(cornerRadius: 25)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.theme.sparkOrange.opacity(0.5), lineWidth: 1.5)
                                )
                                .foregroundColor(Color.theme.sparkOrange)
                                .shadow(color: Color.theme.sparkOrange.opacity(0.2), radius: 10, y: 3)
                        }
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 30)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animateCards)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            animateCards = true
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: "https://payup.app/join/\(session?.sessionKey ?? "")") {
                ShareSheet(items: [shareText, url])
            }
        }
        .alert("Leave Session?", isPresented: $showingLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                sessionManager.leaveSession()
            }
        } message: {
            Text("You can rejoin anytime using the session code")
        }
    }
}

struct SessionDetailsCard: View {
    let session: Session
    @Binding var showingShareSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Session Details", systemImage: "info.circle.fill")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Session Name")
                        .foregroundColor(.white)
                    Spacer()
                    Text(session.name)
                        .foregroundColor(Color.theme.brightCyan)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }

                HStack {
                    Text("Session Code")
                        .foregroundColor(.white)
                    Spacer()
                    Text(session.sessionKey)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Button(action: {
                    showingShareSheet = true
                }) {
                    Label("Share Session Code", systemImage: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .glassCard(cornerRadius: 22)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.theme.brightCyan.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(Color.theme.brightCyan)
                }
                .padding(.top, 5)
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
    }
}

struct ParticipantsCard: View {
    let session: Session
    let currentUserId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Participants (\(session.users.count))", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(session.users) { user in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.theme.brightCyan.opacity(0.3),
                                            Color.theme.electricBlue.opacity(0.1)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }

                        VStack(spacing: 2) {
                            Text(user.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(1)

                            if user.id == currentUserId {
                                Text("You")
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.brightCyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 1)
                                    .background(Color.theme.brightCyan.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
    }
}

struct StatisticsCard: View {
    let session: Session

    var totalAmount: Double {
        session.transactions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Statistics", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }

            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(Color.theme.brightCyan)
                        Text("Total Transactions")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(session.transactions.count)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.brightCyan)
                }

                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(Color.theme.brightCyan)
                        Text("Total Amount Tracked")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", totalAmount))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Color.theme.brightCyan)
                        Text("Created")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(session.createdAt, style: .date)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.theme.brightCyan.opacity(0.8))
                }
            }
        }
        .padding(20)
        .readableGlassCard(cornerRadius: 20)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SessionInfoView()
        .environmentObject(SessionManager())
}