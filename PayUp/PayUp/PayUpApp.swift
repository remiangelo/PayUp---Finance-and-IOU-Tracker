//
//  PayUpApp.swift
//  PayUp
//
//  Created by Rémi Beltram on 2025/09/15.
//

import SwiftUI

@main
struct PayUpApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .environmentObject(subscriptionManager)
        }
    }
}
