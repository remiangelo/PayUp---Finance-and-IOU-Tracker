import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let sessionKey: String
    let name: String
    var users: [User]
    var transactions: [Transaction]
    let createdAt: Date
    let createdBy: String

    init(id: UUID = UUID(), name: String, createdBy: String) {
        self.id = id
        self.sessionKey = Session.generateSessionKey()
        self.name = name
        self.users = []
        self.transactions = []
        self.createdAt = Date()
        self.createdBy = createdBy
    }

    static func generateSessionKey() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }

    mutating func addUser(_ user: User) {
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
        }
    }

    mutating func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }

    func calculateBalances() -> [UUID: Double] {
        var balances: [UUID: Double] = [:]

        for user in users {
            balances[user.id] = 0
        }

        for transaction in transactions {
            balances[transaction.payerId] = (balances[transaction.payerId] ?? 0) + transaction.amount

            let splitAmount = transaction.splitAmount
            for beneficiaryId in transaction.beneficiaryIds {
                balances[beneficiaryId] = (balances[beneficiaryId] ?? 0) - splitAmount
            }
        }

        return balances
    }

    func getSettlements() -> [(from: User, to: User, amount: Double)] {
        let balances = calculateBalances()
        var settlements: [(from: User, to: User, amount: Double)] = []

        var debtors: [(User, Double)] = []
        var creditors: [(User, Double)] = []

        for (userId, balance) in balances {
            if let user = users.first(where: { $0.id == userId }) {
                if balance < 0 {
                    debtors.append((user, -balance))
                } else if balance > 0 {
                    creditors.append((user, balance))
                }
            }
        }

        debtors.sort { $0.1 > $1.1 }
        creditors.sort { $0.1 > $1.1 }

        var debtorIndex = 0
        var creditorIndex = 0

        while debtorIndex < debtors.count && creditorIndex < creditors.count {
            let debtor = debtors[debtorIndex]
            let creditor = creditors[creditorIndex]

            let amount = min(debtor.1, creditor.1)

            if amount > 0.01 {
                settlements.append((from: debtor.0, to: creditor.0, amount: amount))
            }

            debtors[debtorIndex].1 -= amount
            creditors[creditorIndex].1 -= amount

            if debtors[debtorIndex].1 < 0.01 {
                debtorIndex += 1
            }
            if creditors[creditorIndex].1 < 0.01 {
                creditorIndex += 1
            }
        }

        return settlements
    }
}