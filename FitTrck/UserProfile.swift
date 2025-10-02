import Foundation
import SwiftUI

class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var activityLevel: String = "moderate"
    @Published var dietaryRestrictions: [String] = []
    @Published var healthGoals: [String] = []
    @Published var allergies: String = ""
    @Published var preferredCuisines: String = ""
    @Published var cookingSkillLevel: String = "beginner"
    @Published var budgetRange: String = "medium"
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "UserProfile"
    
    init() {
        loadProfile()
    }
    
    func saveProfile() {
        let profileData = ProfileData(
            name: name,
            age: age,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            dietaryRestrictions: dietaryRestrictions,
            healthGoals: healthGoals,
            allergies: allergies,
            preferredCuisines: preferredCuisines,
            cookingSkillLevel: cookingSkillLevel,
            budgetRange: budgetRange
        )
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profileData)
            userDefaults.set(data, forKey: profileKey)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
    
    func loadProfile() {
        guard let data = userDefaults.data(forKey: profileKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            let profileData = try decoder.decode(ProfileData.self, from: data)
            
            name = profileData.name
            age = profileData.age
            height = profileData.height
            weight = profileData.weight
            activityLevel = profileData.activityLevel
            dietaryRestrictions = profileData.dietaryRestrictions
            healthGoals = profileData.healthGoals
            allergies = profileData.allergies
            preferredCuisines = profileData.preferredCuisines
            cookingSkillLevel = profileData.cookingSkillLevel
            budgetRange = profileData.budgetRange
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
    
    func isProfileComplete() -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               age > 0 &&
               !healthGoals.isEmpty
    }
    
    func getContextString() -> String {
        var context = ""
        
        if !name.isEmpty {
            context += "Name: \(name)\n"
        }
        
        if age > 0 {
            context += "Age: \(age)\n"
        }
        
        if height > 0 {
            context += "Height: \(height) cm\n"
        }
        
        if weight > 0 {
            context += "Weight: \(weight) kg\n"
        }
        
        context += "Activity Level: \(activityLevel)\n"
        
        if !healthGoals.isEmpty {
            context += "Health Goals: \(healthGoals.joined(separator: ", "))\n"
        }
        
        if !dietaryRestrictions.isEmpty {
            context += "Dietary Restrictions: \(dietaryRestrictions.joined(separator: ", "))\n"
        }
        
        if !allergies.isEmpty {
            context += "Allergies: \(allergies)\n"
        }
        
        if !preferredCuisines.isEmpty {
            context += "Preferred Cuisines: \(preferredCuisines)\n"
        }
        
        context += "Cooking Skill: \(cookingSkillLevel)\n"
        context += "Budget Range: \(budgetRange)\n"
        
        return context
    }
}

struct ProfileData: Codable {
    let name: String
    let age: Int
    let height: Double
    let weight: Double
    let activityLevel: String
    let dietaryRestrictions: [String]
    let healthGoals: [String]
    let allergies: String
    let preferredCuisines: String
    let cookingSkillLevel: String
    let budgetRange: String
}