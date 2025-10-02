import SwiftUI

struct MealPlannerView: View {
    @State private var selectedDate = Date()
    @State private var selectedMealType: MealType = .breakfast
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    @State private var isGeneratingMeals = false
    @State private var mealPlan: [Date: [MealType: Recipe]] = sampleMealPlan
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Meal Planner")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("AI-powered meal suggestions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { generateMealsForWeek() }) {
                            VStack(spacing: 4) {
                                Image(systemName: "wand.and.stars")
                                    .font(.title2)
                                Text("Generate")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .disabled(isGeneratingMeals)
                    }
                    
                    // Weekly Calendar
                    WeeklyMealCalendar(selectedDate: $selectedDate)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Meal Type Selector
                MealTypeSelector(selectedMealType: $selectedMealType)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Color(.systemGroupedBackground))
                
                // Meal Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Meal Card
                        if let todaysMeal = mealPlan[calendar.startOfDay(for: selectedDate)]?[selectedMealType] {
                            TodaysMealCard(recipe: todaysMeal) {
                                selectedRecipe = todaysMeal
                                showingRecipeDetail = true
                            }
                        } else {
                            EmptyMealCard(mealType: selectedMealType, date: selectedDate) {
                                generateMealForSlot()
                            }
                        }
                        
                        // AI Suggestions
                        AIMealSuggestionsCard(mealType: selectedMealType) { recipe in
                            selectedRecipe = recipe
                            showingRecipeDetail = true
                        }
                        
                        // Nutrition Goals
                        NutritionGoalsCard()
                        
                        // Meal History
                        MealHistoryCard()
                    }
                    .padding()
                }
                .contentShape(Rectangle())
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRecipeDetail) {
            if let recipe = selectedRecipe {
                RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    private func generateMealsForWeek() {
        isGeneratingMeals = true
        // Simulate AI meal generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Generate meals for the week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                    let dayStart = calendar.startOfDay(for: date)
                    mealPlan[dayStart] = [
                        .breakfast: sampleRecipes.randomElement()!,
                        .lunch: sampleRecipes.randomElement()!,
                        .dinner: sampleRecipes.randomElement()!
                    ]
                }
            }
            
            isGeneratingMeals = false
        }
    }
    
    private func generateMealForSlot() {
        let dayStart = calendar.startOfDay(for: selectedDate)
        if mealPlan[dayStart] == nil {
            mealPlan[dayStart] = [:]
        }
        mealPlan[dayStart]?[selectedMealType] = sampleRecipes.randomElement()!
    }
}

// MARK: - Weekly Meal Calendar
struct WeeklyMealCalendar: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 8) {
                        Text(dayFormatter.string(from: date))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(dateFormatter.string(from: date))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.accentColor : Color.clear)
                            )
                        
                        // Meal indicators
                        HStack(spacing: 2) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                Circle()
                                    .fill(mealType.color.opacity(0.7))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}

// MARK: - Meal Type Selector
struct MealTypeSelector: View {
    @Binding var selectedMealType: MealType
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                Button(action: { selectedMealType = mealType }) {
                    VStack(spacing: 6) {
                        Image(systemName: mealType.icon)
                            .font(.title3)
                        Text(mealType.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedMealType == mealType ? .white : mealType.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedMealType == mealType ? mealType.color : Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Today's Meal Card
struct TodaysMealCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Today's Meal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(.accentColor)
                    }
                }
                
                HStack(spacing: 16) {
                    // Recipe image placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(recipe.cuisine.color.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(recipe.cuisine.color)
                                .font(.title2)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            InfoChip(icon: "clock", text: "\(recipe.cookTime) min", color: .blue)
                            InfoChip(icon: "flame.fill", text: "\(recipe.calories) cal", color: .orange)
                            InfoChip(icon: "star.fill", text: String(format: "%.1f", recipe.rating), color: .yellow)
                        }
                        
                        // Ingredients preview
                        Text("With: \(recipe.ingredients.prefix(3).joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    ActionButton(title: "Start Cooking", icon: "play.fill", color: .green) {}
                    ActionButton(title: "Save Recipe", icon: "heart", color: .red) {}
                    ActionButton(title: "Share", icon: "square.and.arrow.up", color: .blue) {}
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Meal Card
struct EmptyMealCard: View {
    let mealType: MealType
    let date: Date
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: mealType.icon)
                .font(.largeTitle)
                .foregroundColor(mealType.color.opacity(0.5))
            
            Text("No \(mealType.displayName.lowercased()) planned")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Let AI suggest the perfect meal for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onGenerate) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Generate Meal")
                }
                .foregroundColor(.white)
                .padding()
                .background(mealType.color)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - AI Meal Suggestions Card
struct AIMealSuggestionsCard: View {
    let mealType: MealType
    let onRecipeTap: (Recipe) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Suggestions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See All") {}
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sampleRecipes.prefix(5), id: \.id) { recipe in
                        SuggestionRecipeCard(recipe: recipe) {
                            onRecipeTap(recipe)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Suggestion Recipe Card
struct SuggestionRecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Recipe image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(recipe.cuisine.color.opacity(0.3))
                    .frame(width: 120, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(recipe.cuisine.color)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(recipe.cookTime)m")
                            .font(.caption2)
                        
                        Spacer()
                        
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", recipe.rating))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(width: 120)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Nutrition Goals Card
struct NutritionGoalsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Nutrition Goals")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                NutritionGoalItem(name: "Calories", current: 1420, goal: 2200, unit: "cal", color: .orange)
                NutritionGoalItem(name: "Protein", current: 85, goal: 120, unit: "g", color: .red)
                NutritionGoalItem(name: "Carbs", current: 180, goal: 250, unit: "g", color: .blue)
                NutritionGoalItem(name: "Fat", current: 45, goal: 80, unit: "g", color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Nutrition Goal Item
struct NutritionGoalItem: View {
    let name: String
    let current: Int
    let goal: Int
    let unit: String
    let color: Color
    
    var progress: Double {
        Double(current) / Double(goal)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(current)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Text("\(goal) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Meal History Card
struct MealHistoryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Meals")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(sampleRecipes.prefix(3), id: \.id) { recipe in
                    HistoryMealItem(recipe: recipe)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - History Meal Item
struct HistoryMealItem: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(recipe.cuisine.color.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(recipe.cuisine.color)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Yesterday • \(recipe.calories) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Supporting Views
struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe image placeholder
                    RoundedRectangle(cornerRadius: 16)
                        .fill(recipe.cuisine.color.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(recipe.cuisine.color)
                                .font(.largeTitle)
                        )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Recipe info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack {
                                InfoChip(icon: "clock", text: "\(recipe.cookTime) min", color: .blue)
                                InfoChip(icon: "flame.fill", text: "\(recipe.calories) cal", color: .orange)
                                InfoChip(icon: "star.fill", text: String(format: "%.1f", recipe.rating), color: .yellow)
                            }
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ingredients")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack {
                                    Image(systemName: "circle")
                                        .font(.caption2)
                                        .foregroundColor(.accentColor)
                                    Text(ingredient)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.accentColor)
                                        .cornerRadius(12)
                                    
                                    Text(instruction)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {}) {
                    Image(systemName: "heart")
                }
            )
        }
    }
}

// MARK: - Data Models
enum MealType: CaseIterable {
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

struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let cuisine: CuisineType
    let cookTime: Int
    let calories: Int
    let rating: Double
    let ingredients: [String]
    let instructions: [String]
}

enum CuisineType {
    case mediterranean, asian, american, mexican, italian
    
    var color: Color {
        switch self {
        case .mediterranean: return .blue
        case .asian: return .red
        case .american: return .green
        case .mexican: return .orange
        case .italian: return .purple
        }
    }
}

// MARK: - Sample Data
let sampleRecipes: [Recipe] = [
    Recipe(
        name: "Mediterranean Quinoa Bowl",
        cuisine: .mediterranean,
        cookTime: 25,
        calories: 520,
        rating: 4.8,
        ingredients: ["Quinoa", "Chickpeas", "Cucumber", "Tomatoes", "Feta", "Olive Oil"],
        instructions: ["Cook quinoa", "Prepare vegetables", "Mix with dressing", "Add feta and serve"]
    ),
    Recipe(
        name: "Herb-Crusted Salmon",
        cuisine: .mediterranean,
        cookTime: 20,
        calories: 480,
        rating: 4.9,
        ingredients: ["Salmon", "Fresh Herbs", "Lemon", "Garlic", "Olive Oil"],
        instructions: ["Prepare herb crust", "Season salmon", "Bake for 15 minutes", "Serve with lemon"]
    ),
    Recipe(
        name: "Asian Stir Fry",
        cuisine: .asian,
        cookTime: 15,
        calories: 380,
        rating: 4.6,
        ingredients: ["Mixed Vegetables", "Soy Sauce", "Ginger", "Garlic", "Sesame Oil"],
        instructions: ["Heat oil", "Add vegetables", "Stir fry", "Add sauce and serve"]
    )
]

let sampleMealPlan: [Date: [MealType: Recipe]] = {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    
    return [
        today: [
            .breakfast: sampleRecipes[0],
            .lunch: sampleRecipes[1],
            .dinner: sampleRecipes[2]
        ]
    ]
}()