import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var showingCreateSession = false
    @State private var showingJoinSession = false

    var body: some View {
        NavigationStack {
            if sessionManager.currentSession == nil {
                WelcomeView(
                    showingCreateSession: $showingCreateSession,
                    showingJoinSession: $showingJoinSession
                )
            } else {
                SessionDashboardView()
            }
        }
        .environmentObject(sessionManager)
        .sheet(isPresented: $showingCreateSession) {
            CreateSessionView()
                .environmentObject(sessionManager)
        }
        .sheet(isPresented: $showingJoinSession) {
            JoinSessionView()
                .environmentObject(sessionManager)
        }
    }
}

#Preview {
    ContentView()
}