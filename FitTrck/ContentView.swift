import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // AI Nutritionist Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Chef")
                }
            
            // Pantry Management with Camera
            PantryView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Pantry")
                }
            
            // AI Meal Planning
            MealPlannerView()
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Meals")
                }
            
            // Taste Profile & Recommendations
            TasteProfileView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Taste")
                }
            
            // Social Features
            SocialView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}