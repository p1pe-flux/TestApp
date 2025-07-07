//
//  ExerciseViewModel.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var filteredExercises: [Exercise] = []
    @Published var selectedCategory: ExerciseCategory?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let exerciseService: ExerciseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    

    init(exerciseService: ExerciseServiceProtocol) {
        self.exerciseService = exerciseService
        setupBindings()
        loadExercises()
        
        // Observar cambios en Core Data
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadExercises()
            }
            .store(in: &cancellables)
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, category in
                self?.filterExercises(searchText: searchText, category: category)
            }
            .store(in: &cancellables)
    }
    
    func loadExercises() {
        isLoading = true
        Task {
            do {
                exercises = try exerciseService.fetchAllExercises()
                filterExercises(searchText: searchText, category: selectedCategory)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func createExercise(name: String, category: String, muscleGroups: [String], notes: String?) async {
        do {
            _ = try exerciseService.createExercise(
                name: name,
                category: category,
                muscleGroups: muscleGroups,
                notes: notes
            )
            loadExercises()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteExercise(_ exercise: Exercise) async {
        do {
            try exerciseService.deleteExercise(exercise)
            loadExercises()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func filterExercises(searchText: String, category: ExerciseCategory?) {
        var filtered = exercises
        
        if let category = category {
            filtered = filtered.filter { $0.wrappedCategory == category.rawValue }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { exercise in
                exercise.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                exercise.wrappedCategory.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredExercises = filtered.sorted { $0.wrappedName < $1.wrappedName }
    }
}
