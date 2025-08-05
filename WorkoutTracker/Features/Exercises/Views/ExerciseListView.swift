//
//  ExerciseListView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel: ExerciseViewModel
    @State private var showingCreateExercise = false
    @State private var exerciseToEdit: Exercise?
    @State private var exerciseToShowProgress: Exercise?
    
    init() {
        let service = ExerciseService(context: PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: ExerciseViewModel(exerciseService: service))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                categoryFilter
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading exercises...")
                } else if viewModel.filteredExercises.isEmpty {
                    emptyState
                } else {
                    exerciseList
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateExercise) {
                ExerciseFormView()
            }
            .sheet(item: $exerciseToEdit) { exercise in
                ExerciseFormView(exercise: exercise)
            }
            .sheet(item: $exerciseToShowProgress) { exercise in
                ExerciseProgressView(exercise: exercise)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search exercises...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }
                
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        systemImage: category.systemImage,
                        color: category.color,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var exerciseList: some View {
        List {
            ForEach(viewModel.filteredExercises) { exercise in
                ExerciseRow(exercise: exercise)
                    .onTapGesture {
                        exerciseToEdit = exercise
                    }
                    .onLongPressGesture {
                        exerciseToShowProgress = exercise
                        HapticManager.shared.impact(.medium)
                    }
                    .contextMenu {
                        Button(action: { exerciseToShowProgress = exercise }) {
                            Label("Ver Progreso", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        
                        Button(action: { exerciseToEdit = exercise }) {
                            Label("Editar", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            Task {
                                await viewModel.deleteExercise(exercise)
                            }
                        }) {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
            .onDelete { offsets in
                deleteExercises(at: offsets)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "figure.strengthtraining.traditional",
            title: "No exercises found",
            message: viewModel.searchText.isEmpty ? "Tap + to add your first exercise" : "Try adjusting your search",
            actionTitle: viewModel.searchText.isEmpty ? "Add Exercise" : "Clear Search",
            action: {
                if viewModel.searchText.isEmpty {
                    showingCreateExercise = true
                } else {
                    viewModel.searchText = ""
                }
            }
        )
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        Task {
            for index in offsets {
                if index < viewModel.filteredExercises.count {
                    await viewModel.deleteExercise(viewModel.filteredExercises[index])
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    var systemImage: String? = nil
    var color: Color = Theme.Colors.primary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}
