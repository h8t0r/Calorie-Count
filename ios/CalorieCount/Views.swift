import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var store: CalorieStore

    var body: some View {
        TabView {
            QuickAddView()
                .tabItem {
                    Label("Quick Add", systemImage: "plus.circle")
                }

            FoodsView()
                .tabItem {
                    Label("Foods", systemImage: "fork.knife")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .overlay(alignment: .top) {
            TotalBanner(total: store.totalCalories)
                .padding(.top, 4)
        }
    }
}

struct TotalBanner: View {
    let total: Int

    var body: some View {
        Text("Today: \(total) kcal")
            .font(.headline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

struct QuickAddView: View {
    @EnvironmentObject private var store: CalorieStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Choose calories to add")
                    .font(.title3)

                Picker("Calories", selection: $store.quickAddValue) {
                    ForEach(Array(stride(from: 0, through: 2000, by: 25)), id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 180)

                Button("Add to Total") {
                    store.addQuickCalories()
                }
                .buttonStyle(.borderedProminent)

                Button("Undo Last Action") {
                    store.undoLastAction()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Quick Add")
            .onAppear { store.refreshForCurrentDayIfNeeded() }
        }
    }
}

struct FoodsView: View {
    @EnvironmentObject private var store: CalorieStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.foodItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("\(item.caloriesPerUnit) kcal each")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Picker("Qty", selection: binding(for: item.id)) {
                            ForEach(0...3, id: \.self) { q in
                                Text("\(q)").tag(q)
                            }
                        }
                        .frame(width: 80)
                        .pickerStyle(.menu)
                    }
                }
            }
            .navigationTitle("Food Items")
            .onAppear { store.refreshForCurrentDayIfNeeded() }
        }
    }

    private func binding(for itemID: UUID) -> Binding<Int> {
        Binding {
            store.selections.first(where: { $0.id == itemID })?.quantity ?? 0
        } set: { newValue in
            store.updateQuantity(for: itemID, newQuantity: newValue)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: CalorieStore
    @State private var name: String = ""
    @State private var calories: Int = 100
    @State private var manualTotal: Int = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Add Food Item") {
                    TextField("Food name", text: $name)
                    Stepper("Calories per unit: \(calories)", value: $calories, in: 0...2000, step: 5)

                    Button("Add Food") {
                        store.addFood(name: name, caloriesPerUnit: calories)
                        name = ""
                        calories = 100
                    }
                }

                Section("Edit Food List") {
                    ForEach(store.foodItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.caloriesPerUnit) kcal")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: store.removeFood)
                }

                Section("Manual Total Override") {
                    Stepper("Set total to: \(manualTotal)", value: $manualTotal, in: 0...15000, step: 25)
                    Button("Apply Manual Total") {
                        store.setManualTotal(manualTotal)
                    }
                }

                Section("Reset") {
                    Button("Reset Day to Zero", role: .destructive) {
                        store.resetToday(to: 0)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                manualTotal = store.totalCalories
                store.refreshForCurrentDayIfNeeded()
            }
        }
    }
}
