import SwiftUI

struct MealPlansViewAll: View {
    @EnvironmentObject var store: MealPlanStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var selectedMealType: MPMealType? = nil
    @State private var selectedTag: String? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var sortDescending: Bool = true
    @State private var showArchived: Bool = true
    @State private var pageSize: Int = 20
    @State private var loadedCount: Int = 20
    @State private var isEditingPlan: MealPlan? = nil
    @State private var alert: (title: String, message: String)? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                #if os(macOS)
                HStack {
                    Text("Meal Plans")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: addNewPlan) {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Add Meal Plan")
                }
                .padding(.horizontal)
                .padding(.top, 12)
                #endif


                FiltersBar(
                    searchText: $searchText,
                    selectedMealType: $selectedMealType,
                    selectedTag: $selectedTag,
                    startDate: $startDate,
                    endDate: $endDate,
                    sortDescending: $sortDescending,
                    showArchived: $showArchived
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
                .padding(.bottom, 4)

                if store.isLoading {
                    ProgressView("Loading meal plans...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = store.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error")
                            .font(.headline)
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Retry") { store.load() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPlans.prefix(loadedCount)) { plan in
                                    MealPlanRow(plan: plan,
                                                onEdit: { isEditingPlan = plan },
                                                onDelete: { store.delete(ids: [plan.id]) },
                                                onToggleArchive: { store.toggleArchive(id: plan.id) })
                                        .id(plan.id)
                                }

                                if loadedCount < filteredPlans.count {
                                    ProgressView()
                                        .onAppear { incrementPage() }
                                }
                            }
                            .padding()
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            #if os(macOS)
            .frame(minWidth: 800, minHeight: 600)
            #endif
            .toolbar {
                #if os(iOS)
                // No custom toolbar items; use system back button from parent
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNewPlan) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Meal Plan")
                }
                #endif
            }
            #if os(iOS)
            .navigationTitle("Meal Plans")
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(item: $isEditingPlan) { plan in
                EditMealPlanView(plan: plan) { updated in
                    store.update(updated)
                }
            }
        }
    }

    private func incrementPage() {
        withAnimation { loadedCount = min(loadedCount + pageSize, filteredPlans.count) }
    }

    private var filteredPlans: [MealPlan] {
        var result = store.plans

        if !showArchived {
            result = result.filter { !$0.isArchived }
        }

        if let start = startDate { result = result.filter { $0.date >= start } }
        if let end = endDate { result = result.filter { $0.date <= end } }

        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) || $0.items.contains(where: { $0.tags.contains(tag) }) }
        }

        if let type = selectedMealType {
            result = result.filter { $0.items.contains(where: { $0.mealType == type }) }
        }

        if !searchText.isEmpty {
            let term = searchText.lowercased()
            result = result.filter { plan in
                plan.items.contains { item in
                    item.recipeName.lowercased().contains(term) ||
                    item.tags.joined(separator: " ").lowercased().contains(term)
                }
            }
        }

        if sortDescending {
            result.sort { $0.date > $1.date }
        } else {
            result.sort { $0.date < $1.date }
        }

        return result
    }

    private func addNewPlan() {
        let new = store.samplePlanFor(date: Date())
        store.add(new)
    }
}

// MARK: - Filters Bar
struct FiltersBar: View {
    @EnvironmentObject var store: MealPlanStore
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Binding var searchText: String
    @Binding var selectedMealType: MPMealType?
    @Binding var selectedTag: String?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var sortDescending: Bool
    @Binding var showArchived: Bool
    @State private var filtersExpanded: Bool = false

    var body: some View {
        // Structured layout with collapsible advanced filters
        VStack(spacing: 10) {
            // Always-visible search
            HStack(spacing: 8) {
                TextField("Search recipes or tags", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .opacity(searchText.isEmpty ? 0 : 1)
            }

            // Collapsible filters to save vertical space on iPhone
            DisclosureGroup(isExpanded: $filtersExpanded) {
                if hSizeClass == .compact {
                    VStack(spacing: 8) {
                        // Row: Meal & Tag
                        HStack(spacing: 8) {
                            Menu {
                                Button("Any", action: { selectedMealType = nil })
                                Divider()
                                ForEach(MPMealType.allCases, id: \.self) { type in
                                    Button(type.displayName) { selectedMealType = type }
                                }
                            } label: {
                                Label(selectedMealType?.displayName ?? "Any Meal", systemImage: selectedMealType?.icon ?? "fork.knife")
                                    .frame(maxWidth: .infinity)
                            }
                            #if os(macOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif

                            Menu {
                                Button("Any", action: { selectedTag = nil })
                                Divider()
                                ForEach(store.allTags, id: \.self) { tag in
                                    Button(tag) { selectedTag = tag }
                                }
                            } label: {
                                Label(selectedTag ?? "Any Tag", systemImage: "tag")
                                    .frame(maxWidth: .infinity)
                            }
                            #if os(macOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif
                        }

                        // Row: From & To
                        HStack(spacing: 8) {
                            DatePicker("From", selection: Binding(get: {
                                startDate ?? Date()
                            }, set: { startDate = $0 }), displayedComponents: .date)
                            #if os(iOS)
                            .datePickerStyle(.compact)
                            #endif

                            DatePicker("To", selection: Binding(get: {
                                endDate ?? Date()
                            }, set: { endDate = $0 }), displayedComponents: .date)
                            #if os(iOS)
                            .datePickerStyle(.compact)
                            #endif
                        }

                        // Row: Archived toggle & sort
                        HStack(spacing: 8) {
                            Toggle(isOn: $showArchived) {
                                Text("Show Archived")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Picker("Sort", selection: Binding(get: {
                                sortDescending ? 0 : 1
                            }, set: { sortDescending = ($0 == 0) })) {
                                Text("Newest First").tag(0)
                                Text("Oldest First").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                        GridRow {
                            Menu {
                                Button("Any", action: { selectedMealType = nil })
                                Divider()
                                ForEach(MPMealType.allCases, id: \.self) { type in
                                    Button(type.displayName) { selectedMealType = type }
                                }
                            } label: {
                                Label(selectedMealType?.displayName ?? "Any Meal", systemImage: selectedMealType?.icon ?? "fork.knife")
                                    .frame(maxWidth: .infinity)
                            }
                            #if os(macOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif

                            Menu {
                                Button("Any", action: { selectedTag = nil })
                                Divider()
                                ForEach(store.allTags, id: \.self) { tag in
                                    Button(tag) { selectedTag = tag }
                                }
                            } label: {
                                Label(selectedTag ?? "Any Tag", systemImage: "tag")
                                    .frame(maxWidth: .infinity)
                            }
                            #if os(macOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif
                        }

                        GridRow {
                            DatePicker("From", selection: Binding(get: {
                                startDate ?? Date()
                            }, set: { startDate = $0 }), displayedComponents: .date)
                            #if os(iOS)
                            .datePickerStyle(.compact)
                            #endif

                            DatePicker("To", selection: Binding(get: {
                                endDate ?? Date()
                            }, set: { endDate = $0 }), displayedComponents: .date)
                            #if os(iOS)
                            .datePickerStyle(.compact)
                            #endif
                        }

                        GridRow {
                            Toggle(isOn: $showArchived) {
                                Text("Show Archived")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Picker("Sort", selection: Binding(get: {
                                sortDescending ? 0 : 1
                            }, set: { sortDescending = ($0 == 0) })) {
                                Text("Newest First").tag(0)
                                Text("Oldest First").tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Filters")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    // Summary of current selections
                    Text(filtersSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .onAppear {
                if !filtersExpanded { filtersExpanded = (hSizeClass != .compact) }
            }
        }
    }

    private var filtersSummary: String {
        var parts: [String] = []
        parts.append(selectedMealType?.displayName ?? "Any Meal")
        parts.append(selectedTag ?? "Any Tag")
        if let s = startDate { parts.append("From: \(dateFormatter.string(from: s))") }
        if let e = endDate { parts.append("To: \(dateFormatter.string(from: e))") }
        parts.append(showArchived ? "Archived: On" : "Archived: Off")
        parts.append(sortDescending ? "Newest" : "Oldest")
        return parts.joined(separator: " • ")
    }
}

// MARK: - Row
struct MealPlanRow: View {
    let plan: MealPlan
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onToggleArchive: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateFormatter.string(from: plan.date))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 8) {
                    Button(action: onToggleArchive) {
                        Label(plan.isArchived ? "Unarchive" : "Archive", systemImage: plan.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down")
                    }
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .labelStyle(IconOnlyLabelStyle())
            }

            VStack(spacing: 10) {
                ForEach(plan.items, id: \.id) { item in
                    MealPlanItemRow(item: item)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                ForEach(plan.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(plan.isArchived ? Color(.systemGray6) : Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(plan.isArchived ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct MealPlanItemRow: View {
    let item: MealPlanItem

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(item.mealType.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.recipeName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(item.calories) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let t = item.time {
                    Text(t)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct EditMealPlanView: View {
    @Environment(\.dismiss) var dismiss
    @State var plan: MealPlan
    var onSave: (MealPlan) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Plan Info") {
                    DatePicker("Date", selection: Binding(get: { plan.date }, set: { plan.date = $0 }))
                    Toggle("Archived", isOn: Binding(get: { plan.isArchived }, set: { plan.isArchived = $0 }))
                    TextField("Tags (comma separated)", text: Binding(get: { plan.tags.joined(separator: ", ") }, set: { plan.tags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }))
                }

                Section("Items") {
                    ForEach(plan.items.indices, id: \.self) { idx in
                        MealPlanItemEditor(item: Binding(get: { plan.items[idx] }, set: { plan.items[idx] = $0 }))
                    }
                    Button("Add Item") {
                        plan.items.append(MealPlanItem(mealType: .breakfast, recipeName: "New Recipe", calories: 0, time: nil, tags: []))
                    }
                }
            }
            .navigationTitle("Edit Meal Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { onSave(plan); dismiss() } }
            }
        }
    }
}

struct MealPlanItemEditor: View {
    @Binding var item: MealPlanItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Meal Type", selection: $item.mealType) {
                ForEach(MPMealType.allCases, id: \.self) { t in
                    Text(t.displayName).tag(t)
                }
            }
            TextField("Recipe Name", text: $item.recipeName)
            TextField("Calories", value: $item.calories, formatter: NumberFormatter())
            TextField("Time (e.g., 7:00 PM)", text: Binding(get: { item.time ?? "" }, set: { item.time = $0.isEmpty ? nil : $0 }))
            TextField("Tags (comma separated)", text: Binding(get: { item.tags.joined(separator: ", ") }, set: { item.tags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }))
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()