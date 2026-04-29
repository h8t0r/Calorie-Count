import Foundation

final class CalorieStore: ObservableObject {
    @Published private(set) var totalCalories: Int = 0
    @Published var quickAddValue: Int = 250
    @Published var foodItems: [FoodItem] = [
        FoodItem(name: "Cereal", caloriesPerUnit: 300),
        FoodItem(name: "Banana", caloriesPerUnit: 105),
        FoodItem(name: "Egg", caloriesPerUnit: 78),
        FoodItem(name: "Chicken Breast", caloriesPerUnit: 280)
    ]
    @Published var selections: [FoodSelection] = []

    private var actionStack: [CalorieAction] = []
    private var dayStamp: String = ""
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let totalCalories = "totalCalories"
        static let quickAddValue = "quickAddValue"
        static let foodItems = "foodItems"
        static let selections = "selections"
        static let actionStack = "actionStack"
        static let dayStamp = "dayStamp"
    }

    init() {
        load()
        refreshForCurrentDayIfNeeded()
        ensureSelectionCoverage()
    }

    func refreshForCurrentDayIfNeeded() {
        let today = Self.dateStamp(Date())
        guard dayStamp != today else { return }

        totalCalories = 0
        quickAddValue = 250
        actionStack.removeAll()
        dayStamp = today

        for idx in selections.indices {
            selections[idx].quantity = 0
        }

        save()
    }

    func addQuickCalories() {
        applyDelta(quickAddValue, source: .quickAdd)
    }

    func undoLastAction() {
        guard let last = actionStack.popLast() else { return }
        totalCalories -= last.delta
        if totalCalories < 0 { totalCalories = 0 }
        save()
    }

    func updateQuantity(for itemID: UUID, newQuantity: Int) {
        guard let item = foodItems.first(where: { $0.id == itemID }) else { return }
        guard let idx = selections.firstIndex(where: { $0.id == itemID }) else { return }

        let oldQuantity = selections[idx].quantity
        selections[idx].quantity = newQuantity

        let deltaUnits = newQuantity - oldQuantity
        let deltaCalories = deltaUnits * item.caloriesPerUnit

        if deltaCalories != 0 {
            applyDelta(deltaCalories, source: .foodAdjustment)
        } else {
            save()
        }
    }

    func addFood(name: String, caloriesPerUnit: Int) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, caloriesPerUnit >= 0 else { return }

        let food = FoodItem(name: trimmed, caloriesPerUnit: caloriesPerUnit)
        foodItems.append(food)
        selections.append(FoodSelection(id: food.id, quantity: 0))
        save()
    }

    func removeFood(at offsets: IndexSet) {
        let ids = offsets.map { foodItems[$0].id }
        foodItems.remove(atOffsets: offsets)
        selections.removeAll { ids.contains($0.id) }
        save()
    }

    func setManualTotal(_ newTotal: Int) {
        let clamped = max(newTotal, 0)
        let delta = clamped - totalCalories
        totalCalories = clamped
        actionStack.append(CalorieAction(delta: delta, source: .manualOverride))
        save()
    }

    func resetToday(to value: Int = 0) {
        totalCalories = max(value, 0)
        actionStack.append(CalorieAction(delta: -totalCalories, source: .reset))
        for idx in selections.indices {
            selections[idx].quantity = 0
        }
        save()
    }

    private func applyDelta(_ delta: Int, source: CalorieAction.Source) {
        totalCalories += delta
        if totalCalories < 0 { totalCalories = 0 }
        actionStack.append(CalorieAction(delta: delta, source: source))
        save()
    }

    private func ensureSelectionCoverage() {
        let existing = Set(selections.map(\.id))
        for item in foodItems where !existing.contains(item.id) {
            selections.append(FoodSelection(id: item.id, quantity: 0))
        }
    }

    private func save() {
        defaults.set(totalCalories, forKey: Keys.totalCalories)
        defaults.set(quickAddValue, forKey: Keys.quickAddValue)
        defaults.set(dayStamp, forKey: Keys.dayStamp)

        let encoder = JSONEncoder()
        defaults.set(try? encoder.encode(foodItems), forKey: Keys.foodItems)
        defaults.set(try? encoder.encode(selections), forKey: Keys.selections)
        defaults.set(try? encoder.encode(actionStack), forKey: Keys.actionStack)
    }

    private func load() {
        totalCalories = defaults.integer(forKey: Keys.totalCalories)

        let quickStored = defaults.integer(forKey: Keys.quickAddValue)
        quickAddValue = quickStored == 0 ? 250 : quickStored

        dayStamp = defaults.string(forKey: Keys.dayStamp) ?? ""

        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: Keys.foodItems),
           let decoded = try? decoder.decode([FoodItem].self, from: data),
           !decoded.isEmpty {
            foodItems = decoded
        }

        if let data = defaults.data(forKey: Keys.selections),
           let decoded = try? decoder.decode([FoodSelection].self, from: data) {
            selections = decoded
        }

        if let data = defaults.data(forKey: Keys.actionStack),
           let decoded = try? decoder.decode([CalorieAction].self, from: data) {
            actionStack = decoded
        }

        if dayStamp.isEmpty {
            dayStamp = Self.dateStamp(Date())
        }
    }

    private static func dateStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
