import Foundation

struct FoodItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var caloriesPerUnit: Int

    init(id: UUID = UUID(), name: String, caloriesPerUnit: Int) {
        self.id = id
        self.name = name
        self.caloriesPerUnit = caloriesPerUnit
    }
}

struct FoodSelection: Identifiable, Codable, Equatable {
    let id: UUID
    var quantity: Int

    init(id: UUID, quantity: Int = 0) {
        self.id = id
        self.quantity = quantity
    }
}

struct CalorieAction: Identifiable, Codable, Equatable {
    enum Source: String, Codable {
        case quickAdd
        case foodAdjustment
        case manualOverride
        case reset
    }

    let id: UUID
    let timestamp: Date
    let delta: Int
    let source: Source

    init(id: UUID = UUID(), timestamp: Date = Date(), delta: Int, source: Source) {
        self.id = id
        self.timestamp = timestamp
        self.delta = delta
        self.source = source
    }
}
