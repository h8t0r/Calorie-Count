import SwiftUI

@main
struct CalorieCountApp: App {
    @StateObject private var store = CalorieStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
