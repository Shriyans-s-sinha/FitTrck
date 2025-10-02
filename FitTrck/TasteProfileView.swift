import SwiftUI

struct TasteProfileView: View {
    @State private var selectedTab: ProfileTab = .preferences
    @State private var showingPreferenceDetail = false
    @State private var selectedPreference: FoodPreference?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Taste Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Your personalized food DNA")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Profile completion
                        VStack(spacing: 4) {
                            Text("87%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2)
                    }
                    
                    // AI Insights Banner
                    AIInsightsBanner()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Tab Selector
                ProfileTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Color(.systemGroupedBackground))
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .preferences:
                            PreferencesContent(onPreferenceTap: { preference in
                                selectedPreference = preference
                                showingPreferenceDetail = true
                            })
                        case .insights:
                            InsightsContent()
                        case .recommendations:
                            RecommendationsContent()
                        }
                    }
                    .padding()
                }
                .contentShape(Rectangle())
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPreferenceDetail) {
            if let preference = selectedPreference {
                PreferenceDetailView(preference: preference)
            }
        }
    }
}

// MARK: - AI Insights Banner
struct AIInsightsBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Learning Update")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Discovered you prefer Mediterranean flavors in the evening")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("View") {
                // Show detailed insights
            }
            .font(.caption)
            .foregroundColor(.purple)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }
}

// MARK: - Profile Tab Selector
struct ProfileTabSelector: View {
    @Binding var selectedTab: ProfileTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.accentColor : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Preferences Content
struct PreferencesContent: View {
    let onPreferenceTap: (FoodPreference) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Cuisine Preferences
            PreferenceCategoryCard(
                title: "Cuisine Preferences",
                subtitle: "Your favorite flavors from around the world",
                preferences: sampleCuisinePreferences,
                onPreferenceTap: onPreferenceTap
            )
            
            // Dietary Restrictions
            PreferenceCategoryCard(
                title: "Dietary Restrictions",
                subtitle: "Foods you avoid or can't eat",
                preferences: sampleDietaryRestrictions,
                onPreferenceTap: onPreferenceTap
            )
            
            // Cooking Style
            PreferenceCategoryCard(
                title: "Cooking Style",
                subtitle: "How you like to prepare your meals",
                preferences: sampleCookingStyles,
                onPreferenceTap: onPreferenceTap
            )
            
            // Flavor Profile
            FlavorProfileCard()
            
            // Meal Timing
            MealTimingCard()
        }
    }
}

// MARK: - Preference Category Card
struct PreferenceCategoryCard: View {
    let title: String
    let subtitle: String
    let preferences: [FoodPreference]
    let onPreferenceTap: (FoodPreference) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(preferences, id: \.id) { preference in
                    PreferenceItem(preference: preference) {
                        onPreferenceTap(preference)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preference Item
struct PreferenceItem: View {
    let preference: FoodPreference
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: preference.icon)
                    .font(.title2)
                    .foregroundColor(preference.color)
                    .frame(width: 40, height: 40)
                    .background(preference.color.opacity(0.1))
                    .cornerRadius(10)
                
                // Name and strength
                VStack(spacing: 2) {
                    Text(preference.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Preference strength indicator
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index < preference.strength ? preference.color : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flavor Profile Card
struct FlavorProfileCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flavor Profile")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FlavorBar(name: "Sweet", value: 0.7, color: .pink)
                FlavorBar(name: "Salty", value: 0.9, color: .blue)
                FlavorBar(name: "Spicy", value: 0.4, color: .red)
                FlavorBar(name: "Sour", value: 0.6, color: .yellow)
                FlavorBar(name: "Umami", value: 0.8, color: .purple)
            }
            
            Text("Based on your meal history and ratings")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Flavor Bar
struct FlavorBar: View {
    let name: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(value * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Meal Timing Card
struct MealTimingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meal Timing Patterns")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                MealTimingItem(meal: "Breakfast", time: "7:30 AM", consistency: 0.85, color: .orange)
                MealTimingItem(meal: "Lunch", time: "12:45 PM", consistency: 0.92, color: .blue)
                MealTimingItem(meal: "Dinner", time: "7:15 PM", consistency: 0.78, color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Meal Timing Item
struct MealTimingItem: View {
    let meal: String
    let time: String
    let consistency: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Usually around \(time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(consistency * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text("consistent")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Insights Content
struct InsightsContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Learning Progress
            LearningProgressCard()
            
            // Taste Evolution
            TasteEvolutionCard()
            
            // Habit Patterns
            HabitPatternsCard()
            
            // Recommendation Accuracy
            RecommendationAccuracyCard()
        }
    }
}

// MARK: - Learning Progress Card
struct LearningProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Learning Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                LearningMetric(title: "Meals Analyzed", value: 23, change: "+5", color: .blue)
                LearningMetric(title: "Preferences Learned", value: 8, change: "+2", color: .green)
                LearningMetric(title: "Patterns Identified", value: 12, change: "+3", color: .purple)
            }
            
            Text("Your AI is getting smarter every meal!")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Learning Metric
struct LearningMetric: View {
    let title: String
    let value: Int
    let change: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Text(change)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

// MARK: - Taste Evolution Card
struct TasteEvolutionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Taste Evolution")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                EvolutionItem(
                    title: "Spice Tolerance",
                    description: "Increased by 15% this month",
                    trend: .up,
                    color: .red
                )
                
                EvolutionItem(
                    title: "Vegetable Variety",
                    description: "Trying 3 new vegetables weekly",
                    trend: .up,
                    color: .green
                )
                
                EvolutionItem(
                    title: "Sweet Cravings",
                    description: "Decreased by 8% recently",
                    trend: .down,
                    color: .pink
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Evolution Item
struct EvolutionItem: View {
    let title: String
    let description: String
    let trend: TrendDirection
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: trend.icon)
                .font(.title3)
                .foregroundColor(trend.color)
                .frame(width: 30, height: 30)
                .background(trend.color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Habit Patterns Card
struct HabitPatternsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eating Patterns")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PatternItem(
                    icon: "clock",
                    title: "Peak Hunger",
                    value: "12:30 PM",
                    description: "Most consistent meal time"
                )
                
                PatternItem(
                    icon: "heart.fill",
                    title: "Favorite Day",
                    value: "Saturday",
                    description: "Highest meal satisfaction"
                )
                
                PatternItem(
                    icon: "leaf.fill",
                    title: "Healthy Streak",
                    value: "12 days",
                    description: "Current healthy choices"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Pattern Item
struct PatternItem: View {
    let icon: String
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30, height: 30)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Recommendation Accuracy Card
struct RecommendationAccuracyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendation Accuracy")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Overall accuracy
                HStack {
                    Text("Overall Match Rate")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("94%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * 0.94, height: 8)
                    }
                }
                .frame(height: 8)
                
                // Breakdown
                VStack(spacing: 8) {
                    AccuracyBreakdown(category: "Breakfast", accuracy: 0.96, color: .orange)
                    AccuracyBreakdown(category: "Lunch", accuracy: 0.92, color: .blue)
                    AccuracyBreakdown(category: "Dinner", accuracy: 0.94, color: .purple)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Accuracy Breakdown
struct AccuracyBreakdown: View {
    let category: String
    let accuracy: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(category)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * accuracy, height: 4)
                }
            }
            .frame(height: 4)
            
            Text("\(Int(accuracy * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

// MARK: - Recommendations Content
struct RecommendationsContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Personalized Suggestions
            PersonalizedSuggestionsCard()
            
            // Trending for You
            TrendingForYouCard()
            
            // Explore New Tastes
            ExploreNewTastesCard()
        }
    }
}

// MARK: - Personalized Suggestions Card
struct PersonalizedSuggestionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Made Just for You")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(personalizedSuggestions, id: \.id) { suggestion in
                    PersonalizedSuggestionItem(suggestion: suggestion)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Personalized Suggestion Item
struct PersonalizedSuggestionItem: View {
    let suggestion: PersonalizedSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(suggestion.color.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: suggestion.icon)
                        .foregroundColor(suggestion.color)
                        .font(.title3)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(suggestion.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("\(Int(suggestion.matchPercentage))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(suggestion.color)
                
                Text("match")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Trending for You Card
struct TrendingForYouCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trending in Your Taste")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(trendingItems, id: \.id) { item in
                        TrendingItem(item: item)
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

// MARK: - Trending Item
struct TrendingItem: View {
    let item: TrendingFoodItem
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.color.opacity(0.3))
                .frame(width: 80, height: 60)
                .overlay(
                    Image(systemName: item.icon)
                        .foregroundColor(item.color)
                        .font(.title2)
                )
            
            VStack(spacing: 2) {
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("+\(item.popularityIncrease)%")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 80)
    }
}

// MARK: - Explore New Tastes Card
struct ExploreNewTastesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expand Your Palate")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(explorationSuggestions, id: \.id) { suggestion in
                    ExplorationSuggestionItem(suggestion: suggestion)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Exploration Suggestion Item
struct ExplorationSuggestionItem: View {
    let suggestion: ExplorationSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: suggestion.icon)
                .font(.title3)
                .foregroundColor(suggestion.color)
                .frame(width: 30, height: 30)
                .background(suggestion.color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Try") {
                // Handle exploration
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(suggestion.color)
            .cornerRadius(8)
        }
    }
}

// MARK: - Preference Detail View
struct PreferenceDetailView: View {
    let preference: FoodPreference
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: preference.icon)
                            .font(.largeTitle)
                            .foregroundColor(preference.color)
                            .frame(width: 80, height: 80)
                            .background(preference.color.opacity(0.1))
                            .cornerRadius(20)
                        
                        Text(preference.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(preference.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Preference strength
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preference Strength")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { level in
                                Button(action: {}) {
                                    Circle()
                                        .fill(level <= preference.strength ? preference.color : Color.gray.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text("\(level)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(level <= preference.strength ? .white : .gray)
                                        )
                                }
                            }
                            
                            Spacer()
                            
                            Text(strengthDescription(preference.strength))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Related foods
                    if !preference.relatedFoods.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Foods")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(preference.relatedFoods, id: \.self) { food in
                                    Text(food)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Preference")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func strengthDescription(_ strength: Int) -> String {
        switch strength {
        case 1: return "Mild"
        case 2: return "Light"
        case 3: return "Moderate"
        case 4: return "Strong"
        case 5: return "Very Strong"
        default: return "Unknown"
        }
    }
}

// MARK: - Data Models
enum ProfileTab: CaseIterable {
    case preferences, insights, recommendations
    
    var displayName: String {
        switch self {
        case .preferences: return "Preferences"
        case .insights: return "Insights"
        case .recommendations: return "For You"
        }
    }
    
    var icon: String {
        switch self {
        case .preferences: return "heart.fill"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .recommendations: return "sparkles"
        }
    }
}

struct FoodPreference: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let strength: Int // 1-5
    let relatedFoods: [String]
}

struct PersonalizedSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let reason: String
    let icon: String
    let color: Color
    let matchPercentage: Double
}

struct TrendingFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let popularityIncrease: Int
}

struct ExplorationSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

enum TrendDirection {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

// MARK: - Sample Data
let sampleCuisinePreferences: [FoodPreference] = [
    FoodPreference(
        name: "Mediterranean",
        description: "Fresh, healthy flavors with olive oil, herbs, and seafood",
        icon: "leaf.fill",
        color: .blue,
        strength: 5,
        relatedFoods: ["Olive Oil", "Feta", "Tomatoes", "Herbs"]
    ),
    FoodPreference(
        name: "Asian",
        description: "Bold flavors with soy, ginger, and aromatic spices",
        icon: "flame.fill",
        color: .red,
        strength: 4,
        relatedFoods: ["Soy Sauce", "Ginger", "Rice", "Noodles"]
    ),
    FoodPreference(
        name: "Mexican",
        description: "Vibrant spices, fresh ingredients, and bold flavors",
        icon: "sun.max.fill",
        color: .orange,
        strength: 3,
        relatedFoods: ["Cilantro", "Lime", "Peppers", "Avocado"]
    ),
    FoodPreference(
        name: "Italian",
        description: "Simple, quality ingredients with pasta, cheese, and herbs",
        icon: "heart.fill",
        color: .green,
        strength: 4,
        relatedFoods: ["Pasta", "Cheese", "Basil", "Tomatoes"]
    )
]

let sampleDietaryRestrictions: [FoodPreference] = [
    FoodPreference(
        name: "Gluten-Free",
        description: "Avoiding wheat, barley, rye, and other gluten-containing grains",
        icon: "xmark.circle.fill",
        color: .red,
        strength: 5,
        relatedFoods: ["Wheat", "Barley", "Rye", "Bread"]
    ),
    FoodPreference(
        name: "Low Sodium",
        description: "Limiting salt intake for better health",
        icon: "drop.fill",
        color: .blue,
        strength: 3,
        relatedFoods: ["Salt", "Processed Foods", "Canned Goods"]
    )
]

let sampleCookingStyles: [FoodPreference] = [
    FoodPreference(
        name: "Quick & Easy",
        description: "Meals that can be prepared in 30 minutes or less",
        icon: "clock.fill",
        color: .green,
        strength: 5,
        relatedFoods: ["One-Pot Meals", "Stir-Fries", "Salads"]
    ),
    FoodPreference(
        name: "Meal Prep",
        description: "Batch cooking for the week ahead",
        icon: "calendar",
        color: .purple,
        strength: 4,
        relatedFoods: ["Containers", "Freezer Meals", "Batch Cooking"]
    )
]

let personalizedSuggestions: [PersonalizedSuggestion] = [
    PersonalizedSuggestion(
        title: "Mediterranean Quinoa Bowl",
        reason: "Matches your love for Mediterranean flavors and healthy grains",
        icon: "leaf.fill",
        color: .blue,
        matchPercentage: 96
    ),
    PersonalizedSuggestion(
        title: "Spicy Asian Stir-Fry",
        reason: "Perfect for your Tuesday evening cooking routine",
        icon: "flame.fill",
        color: .red,
        matchPercentage: 92
    ),
    PersonalizedSuggestion(
        title: "Quick Avocado Toast",
        reason: "Ideal for your busy morning schedule",
        icon: "clock.fill",
        color: .green,
        matchPercentage: 89
    )
]

let trendingItems: [TrendingFoodItem] = [
    TrendingFoodItem(name: "Kimchi", icon: "flame.fill", color: .red, popularityIncrease: 25),
    TrendingFoodItem(name: "Oat Milk", icon: "drop.fill", color: .brown, popularityIncrease: 18),
    TrendingFoodItem(name: "Jackfruit", icon: "leaf.fill", color: .green, popularityIncrease: 32),
    TrendingFoodItem(name: "Tahini", icon: "circle.fill", color: .yellow, popularityIncrease: 15)
]

let explorationSuggestions: [ExplorationSuggestion] = [
    ExplorationSuggestion(
        title: "Try Ethiopian Cuisine",
        description: "Rich spices and unique flavors you haven't explored",
        icon: "globe",
        color: .orange
    ),
    ExplorationSuggestion(
        title: "Experiment with Fermented Foods",
        description: "Great for gut health and new taste experiences",
        icon: "flask.fill",
        color: .purple
    ),
    ExplorationSuggestion(
        title: "Plant-Based Proteins",
        description: "Discover new protein sources beyond your usual choices",
        icon: "leaf.fill",
        color: .green
    )
]