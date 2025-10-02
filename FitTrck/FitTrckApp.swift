import SwiftUI

@main
struct FitTrckApp: App {
    @StateObject private var mealPlanStore = MealPlanStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mealPlanStore)
        }
        #if os(macOS)
        .commands {
            MealPlansCommands()
        }
        #endif

        // Dedicated window for Meal Plans View All
        WindowGroup(id: "mealPlansViewAll") {
            MealPlansViewAll()
                .environmentObject(mealPlanStore)
                .frame(minWidth: 800, minHeight: 600) // Sensible defaults for usability
        }
    }
}

#if os(macOS)
struct MealPlansCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandMenu("Windows") {
            Button("Open Meal Plans") {
                openWindow(id: "mealPlansViewAll")
            }
            .keyboardShortcut("m", modifiers: [.command, .shift])
        }
    }
}
#endif