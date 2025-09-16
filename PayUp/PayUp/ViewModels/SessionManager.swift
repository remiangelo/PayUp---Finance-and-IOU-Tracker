import Foundation
import SwiftUI
import Combine

@MainActor
class SessionManager: ObservableObject {
    @Published var currentSession: Session?
    @Published var currentUser: User?
    @Published var availableSessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "CurrentUser"
    private let sessionsKey = "SavedSessions"

    init() {
        loadSavedData()
    }

    func createSession(name: String, userName: String) {
        let user = User(name: userName)
        var session = Session(name: name, createdBy: user.deviceId)
        session.addUser(user)

        currentUser = user
        currentSession = session
        availableSessions.append(session)
        saveData()
    }

    func joinSession(sessionKey: String, userName: String) {
        guard let sessionIndex = availableSessions.firstIndex(where: { $0.sessionKey == sessionKey.uppercased() }) else {
            errorMessage = "Session with key \(sessionKey) not found"
            return
        }

        let user = User(name: userName)
        availableSessions[sessionIndex].addUser(user)

        currentUser = user
        currentSession = availableSessions[sessionIndex]
        saveData()
    }

    func addTransaction(payerId: UUID, beneficiaryIds: [UUID], amount: Double, description: String) {
        guard var session = currentSession,
              let user = currentUser else { return }

        let transaction = Transaction(
            payerId: payerId,
            beneficiaryIds: beneficiaryIds,
            amount: amount,
            description: description,
            createdBy: user.id
        )

        session.addTransaction(transaction)

        if let index = availableSessions.firstIndex(where: { $0.id == session.id }) {
            availableSessions[index] = session
        }
        currentSession = session
        saveData()
    }

    func leaveSession() {
        currentSession = nil
        saveData()
    }

    func deleteSession(_ session: Session) {
        availableSessions.removeAll { $0.id == session.id }
        if currentSession?.id == session.id {
            currentSession = nil
        }
        saveData()
    }

    private func saveData() {
        if let currentUser = currentUser {
            if let encoded = try? JSONEncoder().encode(currentUser) {
                userDefaults.set(encoded, forKey: currentUserKey)
            }
        }

        if let encoded = try? JSONEncoder().encode(availableSessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }

    private func loadSavedData() {
        if let userData = userDefaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }

        if let sessionsData = userDefaults.data(forKey: sessionsKey),
           let sessions = try? JSONDecoder().decode([Session].self, from: sessionsData) {
            availableSessions = sessions
        }
    }
}