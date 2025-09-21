import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showingCreateSession = false
    @State private var showingJoinSession = false
    @State private var showLaunchScreen = true
    @State private var showingReceiptScanner = false

    var body: some View {
        ZStack {
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
            .sheet(isPresented: $subscriptionManager.showPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
            .sheet(isPresented: $showingReceiptScanner) {
                ReceiptScannerView()
                    .environmentObject(sessionManager)
                    .environmentObject(subscriptionManager)
            }
            .opacity(showLaunchScreen ? 0 : 1)
            .animation(.easeIn(duration: 0.5), value: showLaunchScreen)

            if showLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}