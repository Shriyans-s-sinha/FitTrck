import SwiftUI
import AVFoundation
import UIKit

struct PantryView: View {
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var pantryItems: [PantryItem] = samplePantryItems
    @State private var searchText = ""
    @State private var selectedCategory: PantryCategory = .all
    
    var filteredItems: [PantryItem] {
        let categoryFiltered = selectedCategory == .all ? pantryItems : pantryItems.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with scan button
                    PantryHeader(pantryItemsCount: pantryItems.count, showingCamera: $showingCamera)
                    // Search and Filter
                    VStack(spacing: 12) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search pantry items...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        
                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(PantryCategory.allCases, id: \.self) { (category: PantryCategory) in
                                    CategoryChip(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Color(.systemGroupedBackground))
                    
                    // Pantry Items List
                    PantryListSection(filteredItems: filteredItems)
                }
            }
            .contentShape(Rectangle())
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage, isAnalyzing: $isAnalyzing)
        }
        .onChange(of: selectedImage) {
            if selectedImage != nil {
                analyzeImage()
            }
        }
    }
    
    private func analyzeImage() {
        isAnalyzing = true
        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Add mock detected items
            let newItems = [
                PantryItem(name: "Tomatoes", category: .vegetables, quantity: "3 pieces", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, freshness: .fresh),
                PantryItem(name: "Milk", category: .dairy, quantity: "1 carton", expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, freshness: .fresh),
                PantryItem(name: "Bread", category: .grains, quantity: "1 loaf", expiryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, freshness: .expiringSoon)
            ]
            
            pantryItems.append(contentsOf: newItems)
            isAnalyzing = false
            selectedImage = nil
        }
    }
}

// MARK: - AI Insights Card
struct AIInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("AI Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                InsightRow(
                    icon: "exclamationmark.triangle.fill",
                    text: "3 items expiring in 2 days",
                    color: .orange
                )
                
                InsightRow(
                    icon: "sparkles",
                    text: "Perfect ingredients for Mediterranean Bowl",
                    color: .purple
                )
                
                InsightRow(
                    icon: "cart.fill",
                    text: "Low on protein sources",
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

// MARK: - Insight Row
struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: PantryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Pantry Item Card
struct PantryItemCard: View {
    let item: PantryItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Item image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(item.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: item.category.icon)
                            .foregroundColor(item.category.color)
                            .font(.title3)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        FreshnessIndicator(freshness: item.freshness)
                    }
                    
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Expires: \(item.expiryDate, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(item.freshness == .expiringSoon ? .orange : .secondary)
                        
                        Spacer()
                        
                        Text(item.category.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.category.color.opacity(0.2))
                            .foregroundColor(item.category.color)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Freshness Indicator
struct FreshnessIndicator: View {
    let freshness: FreshnessLevel
    
    var body: some View {
        Circle()
            .fill(freshness.color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isAnalyzing: Bool
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Data Models
struct PantryItem: Identifiable {
    let id = UUID()
    let name: String
    let category: PantryCategory
    let quantity: String
    let expiryDate: Date
    let freshness: FreshnessLevel
}

enum PantryCategory: CaseIterable {
    case all, vegetables, fruits, dairy, meat, grains, spices, beverages, snacks
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .vegetables: return "Vegetables"
        case .fruits: return "Fruits"
        case .dairy: return "Dairy"
        case .meat: return "Meat"
        case .grains: return "Grains"
        case .spices: return "Spices"
        case .beverages: return "Beverages"
        case .snacks: return "Snacks"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .vegetables: return "leaf"
        case .fruits: return "apple"
        case .dairy: return "drop"
        case .meat: return "fish"
        case .grains: return "grain"
        case .spices: return "sparkles"
        case .beverages: return "cup.and.saucer"
        case .snacks: return "bag"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .vegetables: return .green
        case .fruits: return .red
        case .dairy: return .blue
        case .meat: return .pink
        case .grains: return .brown
        case .spices: return .orange
        case .beverages: return .cyan
        case .snacks: return .purple
        }
    }
}

enum FreshnessLevel {
    case fresh, expiringSoon, expired
    
    var color: Color {
        switch self {
        case .fresh: return .green
        case .expiringSoon: return .orange
        case .expired: return .red
        }
    }
}

// MARK: - Sample Data
let samplePantryItems: [PantryItem] = [
    PantryItem(name: "Spinach", category: .vegetables, quantity: "1 bag", expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, freshness: .fresh),
    PantryItem(name: "Chicken Breast", category: .meat, quantity: "2 lbs", expiryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, freshness: .expiringSoon),
    PantryItem(name: "Greek Yogurt", category: .dairy, quantity: "1 container", expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, freshness: .fresh),
    PantryItem(name: "Quinoa", category: .grains, quantity: "2 cups", expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!, freshness: .fresh),
    PantryItem(name: "Avocado", category: .fruits, quantity: "3 pieces", expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, freshness: .expiringSoon),
    PantryItem(name: "Olive Oil", category: .spices, quantity: "1 bottle", expiryDate: Calendar.current.date(byAdding: .month, value: 12, to: Date())!, freshness: .fresh),
    PantryItem(name: "Almonds", category: .snacks, quantity: "1 bag", expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!, freshness: .fresh),
    PantryItem(name: "Orange Juice", category: .beverages, quantity: "1 carton", expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, freshness: .fresh)
]

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()


struct PantryHeader: View {
    var pantryItemsCount: Int
    @Binding var showingCamera: Bool
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Pantry")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(pantryItemsCount) items • Last updated 2h ago")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { showingCamera = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Scan")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            AIInsightsCard()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct PantryListSection: View {
    let filteredItems: [PantryItem]
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredItems) { (item: PantryItem) in
                PantryItemCard(item: item) {
                    // Handle item tap
                }
            }
        }
        .padding()
    }
}