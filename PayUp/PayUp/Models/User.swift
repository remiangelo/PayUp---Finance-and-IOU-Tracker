import Foundation
import UIKit

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let deviceId: String
    let joinedAt: Date

    init(id: UUID = UUID(), name: String, deviceId: String? = nil) {
        self.id = id
        self.name = name
        self.deviceId = deviceId ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        self.joinedAt = Date()
    }
}