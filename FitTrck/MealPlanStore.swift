import SwiftUI
import Foundation

// MARK: - Meal Plan Models
enum MPMealType: String, Codable, CaseIterable, Hashable {
    case breakfast, lunch, dinner, snack
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.rise"
        case .lunch: return "sun.max"
        case .dinner: return "moon"
        case .snack: return "leaf"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}

struct MealPlanItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var mealType: MPMealType
    var recipeName: String
    var calories: Int
    var time: String?
    var tags: [String]
}

struct MealPlan: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var date: Date
    var items: [MealPlanItem]
    var isArchived: Bool
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - Persistent Store
final class MealPlanStore: ObservableObject {
    @Published var plans: [MealPlan] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let fileName = "mealplans.json"
    private let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        enc.dateEncodingStrategy = .iso8601
        return enc
    }()
    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()
    
    init() {
        load()
        if plans.isEmpty {
            seed()
        }
    }
    
    // MARK: File URL
    private func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(fileName)
    }
    
    // MARK: CRUD / Persistence
    func load() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        let url = fileURL()
        do {
            let data = try Data(contentsOf: url)
            let loaded = try decoder.decode([MealPlan].self, from: data)
            self.plans = loaded
            sortPlans()
        } catch {
            // If file not found, start empty
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileReadNoSuchFileError {
                self.plans = []
            } else {
                self.errorMessage = "Failed to load meal plans: \(error.localizedDescription)"
                self.plans = []
            }
        }
    }
    
    func save() {
        do {
            let data = try encoder.encode(plans)
            try data.write(to: fileURL(), options: .atomic)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save meal plans: \(error.localizedDescription)"
        }
    }
    
    func sortPlans() {
        plans.sort { $0.date > $1.date }
    }
    
    func add(_ plan: MealPlan) {
        plans.append(plan)
        sortPlans()
        save()
    }
    
    func update(_ plan: MealPlan) {
        if let idx = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[idx] = plan
            plans[idx].updatedAt = Date()
            sortPlans()
            save()
        }
    }
    
    func delete(ids: [UUID]) {
        plans.removeAll { ids.contains($0.id) }
        save()
    }
    
    func delete(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
        save()
    }
    
    func toggleArchive(id: UUID) {
        guard let idx = plans.firstIndex(where: { $0.id == id }) else { return }
        plans[idx].isArchived.toggle()
        plans[idx].updatedAt = Date()
        save()
    }
    
    // MARK: Helpers
    var allTags: [String] {
        let base = plans.flatMap { $0.tags } + plans.flatMap { $0.items.flatMap { $0.tags } }
        return Array(Set(base)).sorted()
    }
    
    func samplePlanFor(date: Date) -> MealPlan {
        let day = Calendar.current.startOfDay(for: date)
        let items = [
            MealPlanItem(mealType: .breakfast, recipeName: "Mediterranean Scramble", calories: 420, time: "8:00 AM", tags: ["Eggs","Feta","Spinach","Tomatoes"]),
            MealPlanItem(mealType: .lunch, recipeName: "Quinoa Power Bowl", calories: 520, time: "12:30 PM", tags: ["Quinoa","Chickpeas","Avocado","Cucumber"]),
            MealPlanItem(mealType: .dinner, recipeName: "Herb-Crusted Salmon", calories: 480, time: "7:00 PM", tags: ["Salmon","Herbs","Sweet Potato","Broccoli"])
        ]
        return MealPlan(date: day, items: items, isArchived: false, tags: ["Mediterranean","High Protein"], createdAt: Date(), updatedAt: Date())
    }
    
    private func seed() {
        let today = Calendar.current.startOfDay(for: Date())
        let current = samplePlanFor(date: today)
        add(current)
        // Create a few archived historical plans
        for i in 1...12 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            var plan = samplePlanFor(date: date)
            plan.isArchived = true
            plan.tags = ["Archive"]
            add(plan)
        }
    }
}