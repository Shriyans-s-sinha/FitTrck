import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showingHealthGoals = false
    @State private var showingDietaryRestrictions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Set Up Your Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Help FitTrck provide personalized nutrition advice")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Personal Information Section
                    ProfileSection(title: "Personal Information", icon: "person.fill") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Name",
                                text: $userProfile.name,
                                placeholder: "Enter your name"
                            )
                            
                            HStack(spacing: 16) {
                                CustomTextField(
                                    title: "Age",
                                    text: Binding(
                                        get: { userProfile.age > 0 ? String(userProfile.age) : "" },
                                        set: { userProfile.age = Int($0) ?? 0 }
                                    ),
                                    placeholder: "Age"
                                )
                                .keyboardType(.numberPad)
                                
                                CustomTextField(
                                    title: "Weight (kg)",
                                    text: Binding(
                                        get: { userProfile.weight > 0 ? String(format: "%.1f", userProfile.weight) : "" },
                                        set: { userProfile.weight = Double($0) ?? 0.0 }
                                    ),
                                    placeholder: "Weight"
                                )
                                .keyboardType(.decimalPad)
                            }
                            
                            HStack(spacing: 16) {
                                CustomTextField(
                                    title: "Height (cm)",
                                    text: Binding(
                                        get: { userProfile.height > 0 ? String(format: "%.1f", userProfile.height) : "" },
                                        set: { userProfile.height = Double($0) ?? 0.0 }
                                    ),
                                    placeholder: "Height"
                                )
                                .keyboardType(.decimalPad)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Activity Level")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Picker("Activity Level", selection: $userProfile.activityLevel) {
                                        Text("Sedentary").tag("sedentary")
                                        Text("Light").tag("light")
                                        Text("Moderate").tag("moderate")
                                        Text("Active").tag("active")
                                        Text("Very Active").tag("very_active")
                                    }
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    // Health Goals Section
                    ProfileSection(title: "Health Goals", icon: "target") {
                        VStack(spacing: 12) {
                            Button(action: { showingHealthGoals = true }) {
                                HStack {
                                    Text(userProfile.healthGoals.isEmpty ? "Select your health goals" : "\(userProfile.healthGoals.count) goals selected")
                                        .foregroundColor(userProfile.healthGoals.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            if !userProfile.healthGoals.isEmpty {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(userProfile.healthGoals, id: \.self) { goal in
                                        Text(goal)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.accentColor.opacity(0.1))
                                            .foregroundColor(.accentColor)
                                            .cornerRadius(16)
                                    }
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                    }
                    
                    // Dietary Preferences Section
                    ProfileSection(title: "Dietary Preferences", icon: "leaf.fill") {
                        VStack(spacing: 16) {
                            Button(action: { showingDietaryRestrictions = true }) {
                                HStack {
                                    Text(userProfile.dietaryRestrictions.isEmpty ? "Select dietary restrictions" : "\(userProfile.dietaryRestrictions.count) restrictions selected")
                                        .foregroundColor(userProfile.dietaryRestrictions.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            if !userProfile.dietaryRestrictions.isEmpty {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(userProfile.dietaryRestrictions, id: \.self) { restriction in
                                        Text(restriction)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.orange.opacity(0.1))
                                            .foregroundColor(.orange)
                                            .cornerRadius(16)
                                    }
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                            
                            CustomTextField(
                                title: "Allergies",
                                text: $userProfile.allergies,
                                placeholder: "List any food allergies"
                            )
                        }
                    }
                    
                    // Preferences Section
                    ProfileSection(title: "Cooking Preferences", icon: "fork.knife") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Preferred Cuisines",
                                text: $userProfile.preferredCuisines,
                                placeholder: "e.g., Italian, Asian, Mediterranean"
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cooking Skill Level")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Cooking Skill", selection: $userProfile.cookingSkillLevel) {
                                    Text("Beginner").tag("beginner")
                                    Text("Intermediate").tag("intermediate")
                                    Text("Advanced").tag("advanced")
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Budget Range")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Budget", selection: $userProfile.budgetRange) {
                                    Text("Low").tag("low")
                                    Text("Medium").tag("medium")
                                    Text("High").tag("high")
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .contentShape(Rectangle())
            .navigationTitle("Profile Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfile.saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isProfileValid)
                }
            }
        }
        .sheet(isPresented: $showingHealthGoals) {
            HealthGoalsSelectionView(selectedGoals: $userProfile.healthGoals)
        }
        .sheet(isPresented: $showingDietaryRestrictions) {
            DietaryRestrictionsSelectionView(selectedRestrictions: $userProfile.dietaryRestrictions)
        }
    }
    
    private var isProfileValid: Bool {
        !userProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        userProfile.age > 0 &&
        !userProfile.healthGoals.isEmpty
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

struct HealthGoalsSelectionView: View {
    @Binding var selectedGoals: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let availableGoals = [
        "Weight Loss",
        "Weight Gain", 
        "Muscle Gain",
        "Weight Maintenance",
        "Heart Health",
        "Diabetes Management",
        "Digestive Health",
        "Energy Boost",
        "Immune Support",
        "Anti-Inflammatory"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableGoals, id: \.self) { goal in
                    HStack {
                        Text(goal)
                        Spacer()
                        if selectedGoals.contains(goal) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.removeAll { $0 == goal }
                            } else {
                                selectedGoals.append(goal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Health Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DietaryRestrictionsSelectionView: View {
    @Binding var selectedRestrictions: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let availableRestrictions = [
        "Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Dairy-Free",
        "Ketogenic",
        "Paleo",
        "Low-Carb",
        "Low-Sodium",
        "Diabetic-Friendly",
        "Halal",
        "Kosher"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableRestrictions, id: \.self) { restriction in
                    HStack {
                        Text(restriction)
                        Spacer()
                        if selectedRestrictions.contains(restriction) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if selectedRestrictions.contains(restriction) {
                                selectedRestrictions.removeAll { $0 == restriction }
                            } else {
                                selectedRestrictions.append(restriction)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dietary Restrictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileSetupView(userProfile: UserProfile())
}