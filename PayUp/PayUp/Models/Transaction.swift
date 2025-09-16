import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let payerId: UUID
    let beneficiaryIds: [UUID]
    let amount: Double
    let description: String
    let createdAt: Date
    let createdBy: UUID

    init(id: UUID = UUID(), payerId: UUID, beneficiaryIds: [UUID], amount: Double, description: String, createdBy: UUID) {
        self.id = id
        self.payerId = payerId
        self.beneficiaryIds = beneficiaryIds
        self.amount = amount
        self.description = description
        self.createdAt = Date()
        self.createdBy = createdBy
    }

    var splitAmount: Double {
        return amount / Double(beneficiaryIds.count)
    }
}