import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: MealPlanStore
    @State private var selectedDate = Date()
    @State private var goInlineLink: Bool = false
    @State private var routeToMealPlans: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Greeting & Daily Insight
                    AIGreetingCard()
                    
                    // Today's Meal Plan
                    TodaysMealPlanCard()
                    
                    // Pantry Status & Quick Actions
                    HStack(spacing: 15) {
                        PantryStatusCard()
                        QuickActionsCard()
                    }
                    
                    // Nutrition Progress
                    NutritionProgressCard()
                    
                    // AI Suggestions
                    AISuggestionsCard()
                    
                    // Habit Streak
                    HabitStreakCard()
                    
                    // Recent Activity
                    RecentActivityCard()
                }
                .padding(.horizontal)
            }
            .contentShape(Rectangle())
            .navigationTitle("Your AI Nutritionist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { value in
                switch value {
                case "mealPlansViewAll":
                    MealPlansViewAll()
                        .environmentObject(store)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - AI Greeting Card
struct AIGreetingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good morning, Chef! 👨‍🍳")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Based on your pantry, I've got 3 amazing meals ready for you today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            
            // Quick insight
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Your taste profile shows you love Mediterranean flavors - perfect for today's suggestions!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Today's Meal Plan Card
struct TodaysMealPlanCard: View {
    @EnvironmentObject var store: MealPlanStore
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Meal Plan")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                #if os(macOS)
                Button("View All") {
                    openWindow(id: "mealPlansViewAll")
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                #else
                NavigationLink(value: "mealPlansViewAll") {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                #endif
            }
            
            // Meal cards
            VStack(spacing: 12) {
                MealCard(
                    mealType: "Breakfast",
                    mealName: "Mediterranean Scramble",
                    time: "8:00 AM",
                    calories: 420,
                    ingredients: ["Eggs", "Feta", "Spinach", "Tomatoes"],
                    isCompleted: true
                )
            }
        }
    }
}

// Add destination handling at a top-level extension within DashboardView file
struct MealCard: View {
    let mealType: String
    let mealName: String
    let time: String
    let calories: Int
    let ingredients: [String]
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type indicator
            VStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.orange)
                    .frame(width: 12, height: 12)
                Text(mealType)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mealName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(calories) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Ingredients
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ingredients, id: \.self) { ingredient in
                            Text(ingredient)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Button(action: {}) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "play.circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Pantry Status Card
struct PantryStatusCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "refrigerator")
                    .foregroundColor(.blue)
                Text("Pantry")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text("18 items")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last scanned 2h ago")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Scan Now") {
                // Action to scan pantry
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                QuickActionButton(icon: "camera", title: "Scan Food", color: .green)
                QuickActionButton(icon: "wand.and.stars", title: "AI Suggest", color: .purple)
                QuickActionButton(icon: "heart", title: "Save Recipe", color: .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Nutrition Progress Card
struct NutritionProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Nutrition")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                // Calories
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.65)
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("1,420")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("/ 2,200")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text("Calories")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Macros
                VStack(alignment: .leading, spacing: 12) {
                    MacroProgressBar(name: "Protein", current: 85, goal: 120, color: .red)
                    MacroProgressBar(name: "Carbs", current: 180, goal: 250, color: .blue)
                    MacroProgressBar(name: "Fat", current: 45, goal: 80, color: .green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Macro Progress Bar
struct MacroProgressBar: View {
    let name: String
    let current: Int
    let goal: Int
    let color: Color
    
    var progress: Double {
        Double(current) / Double(goal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text("\(current)g / \(goal)g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - AI Suggestions Card
struct AISuggestionsCard: View {
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
            
            VStack(spacing: 12) {
                SuggestionItem(
                    icon: "sparkles",
                    title: "Try Mediterranean Bowl",
                    subtitle: "Based on your taste profile",
                    color: .purple
                )
                
                SuggestionItem(
                    icon: "leaf",
                    title: "Add more greens",
                    subtitle: "You're 2 servings short today",
                    color: .green
                )
                
                SuggestionItem(
                    icon: "drop",
                    title: "Hydration reminder",
                    subtitle: "Drink 2 more glasses of water",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Suggestion Item
struct SuggestionItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Habit Streak Card
struct HabitStreakCard: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cooking Streak")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("7")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Keep it up! 🔥")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Streak visualization
            HStack(spacing: 4) {
                ForEach(0..<7) { day in
                    Circle()
                        .fill(day < 7 ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Recent Activity Card
struct RecentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ActivityItem(
                    icon: "camera.fill",
                    title: "Scanned pantry",
                    time: "2 hours ago",
                    color: .blue
                )
                
                ActivityItem(
                    icon: "heart.fill",
                    title: "Saved Mediterranean Bowl",
                    time: "Yesterday",
                    color: .red
                )
                
                ActivityItem(
                    icon: "person.2.fill",
                    title: "Joined 30-day challenge",
                    time: "2 days ago",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Activity Item
struct ActivityItem: View {
    let icon: String
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 8) {
                    Text(dayLetter(for: date))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.accentColor : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(calendar.isDate(date, inSameDayAs: Date()) ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let goal: Int?
    let progress: Double?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let goal = goal {
                    Text("\(value)/\(goal)")
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct ActivitySummaryCard: View {
    let steps: Int
    let stepGoal: Int
    let weightLifting: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                // Circular Progress for Steps
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: min(Double(steps) / Double(stepGoal), 1.0))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Image(systemName: "figure.walk")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text("Steps")
                            .font(.subheadline)
                        Spacer()
                        Text("+\(steps - stepGoal + 282)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(.blue)
                        Text("Weight lifting")
                            .font(.subheadline)
                        Spacer()
                        Text("+\(weightLifting)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct WaterIntakeCard: View {
    let current: Int
    let goal: Int
    @State private var showingWaterLog = false
    
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Water")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("\(current) fl oz (\(current/8) cups)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct NutritionOverviewCard: View {
    let protein: (current: Int, goal: Int)
    let carbs: (current: Int, goal: Int)
    let fat: (current: Int, goal: Int)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                MacroRow(
                    name: "Protein",
                    current: protein.current,
                    goal: protein.goal,
                    color: .red,
                    unit: "g"
                )
                
                MacroRow(
                    name: "Carbs",
                    current: carbs.current,
                    goal: carbs.goal,
                    color: .orange,
                    unit: "g"
                )
                
                MacroRow(
                    name: "Fat",
                    current: fat.current,
                    goal: fat.goal,
                    color: .purple,
                    unit: "g"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct MacroRow: View {
    let name: String
    let current: Int
    let goal: Int
    let color: Color
    let unit: String
    
    var progress: Double {
        Double(current) / Double(goal)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            
            ProgressView(value: min(progress, 1.0))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            Text("\(current)\(unit)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

struct RecentlyLoggedSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recently logged")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                RecentLogItem(
                    image: "🥑",
                    title: "Eggs, Avocado, and Toast",
                    time: "12:42 PM",
                    calories: 450,
                    protein: 20,
                    carbs: 40,
                    fat: 25
                )
                
                RecentLogItem(
                    image: "🏋️‍♂️",
                    title: "Weight lifting",
                    time: "12:42 PM",
                    calories: 50,
                    intensity: "Medium",
                    duration: "15 Mins"
                )
            }
        }
    }
}

struct RecentLogItem: View {
    let image: String
    let title: String
    let time: String
    let calories: Int
    let protein: Int?
    let carbs: Int?
    let fat: Int?
    let intensity: String?
    let duration: String?
    
    init(image: String, title: String, time: String, calories: Int, protein: Int? = nil, carbs: Int? = nil, fat: Int? = nil, intensity: String? = nil, duration: String? = nil) {
        self.image = image
        self.title = title
        self.time = time
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.intensity = intensity
        self.duration = duration
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(image)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let protein = protein, let carbs = carbs, let fat = fat {
                    HStack(spacing: 12) {
                        MacroTag(value: protein, unit: "g", color: .red)
                        MacroTag(value: carbs, unit: "g", color: .orange)
                        MacroTag(value: fat, unit: "g", color: .purple)
                    }
                } else if let intensity = intensity, let duration = duration {
                    HStack(spacing: 12) {
                        Text("💪 Intensity: \(intensity)")
                            .font(.caption)
                        Text("⏱️ \(duration)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("\(calories) calories")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MacroTag: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(value)\(unit)")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    DashboardView()
}