//
//  ExerciseProgressViewModel.swift
//  WorkoutTracker
//
//  ViewModel para gestionar el progreso histórico de ejercicios
//

import Foundation
import CoreData

// MARK: - Data Models

struct ExerciseWorkoutData: Identifiable {
    let id = UUID()
    let workout: Workout
    let date: Date
    let sets: [SetData]
    
    var maxWeight: Double {
        sets.map { $0.weight }.max() ?? 0
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}

struct SetData: Identifiable {
    let id = UUID()
    let setNumber: Int
    let weight: Double
    let reps: Int
    let isPersonalRecord: Bool
    
    var volume: Double {
        weight * Double(reps)
    }
}

// MARK: - ViewModel

@MainActor
class ExerciseProgressViewModel: ObservableObject {
    @Published var recentWorkouts: [ExerciseWorkoutData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let exercise: Exercise
    private let context: NSManagedObjectContext
    private let maxSessionsToShow = 3
    
    // Calculated properties
    var latestMaxWeight: Double {
        recentWorkouts.first?.maxWeight ?? 0
    }
    
    var previousMaxWeight: Double? {
        guard recentWorkouts.count > 1 else { return nil }
        return recentWorkouts[1].maxWeight
    }
    
    var latestTotalVolume: Double {
        recentWorkouts.first?.totalVolume ?? 0
    }
    
    var previousTotalVolume: Double? {
        guard recentWorkouts.count > 1 else { return nil }
        return recentWorkouts[1].totalVolume
    }
    
    init(exercise: Exercise, context: NSManagedObjectContext) {
        self.exercise = exercise
        self.context = context
    }
    
    func loadRecentWorkouts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let workoutData = try await fetchRecentWorkouts()
                self.recentWorkouts = workoutData
                self.isLoading = false
            } catch {
                self.errorMessage = "Error al cargar el historial: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchRecentWorkouts() async throws -> [ExerciseWorkoutData] {
        let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@ AND workout.date != nil", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutExercise.workout?.date, ascending: false)]
        request.fetchLimit = maxSessionsToShow
        
        let workoutExercises = try context.fetch(request)
        
        // Obtener el peso máximo histórico para identificar PRs
        let allTimeMaxWeight = try fetchAllTimeMaxWeight()
        
        return workoutExercises.compactMap { workoutExercise in
            guard let workout = workoutExercise.workout,
                  let date = workout.date else { return nil }
            
            let sets = workoutExercise.setsArray
                .filter { $0.completed && $0.weight > 0 && $0.reps > 0 }
                .map { set in
                    // Convertir del formato de almacenamiento (kg) al formato del usuario
                    let weightInUserUnit = UserPreferences.shared.convertFromStorageUnit(set.weight)
                    
                    return SetData(
                        setNumber: Int(set.setNumber),
                        weight: weightInUserUnit,
                        reps: Int(set.reps),
                        isPersonalRecord: set.weight >= allTimeMaxWeight && workoutExercise == workoutExercises.first
                    )
                }
                .sorted { $0.setNumber < $1.setNumber }
            
            guard !sets.isEmpty else { return nil }
            
            return ExerciseWorkoutData(
                workout: workout,
                date: date,
                sets: sets
            )
        }
    }
    
    private func fetchAllTimeMaxWeight() throws -> Double {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.predicate = NSPredicate(
            format: "workoutExercise.exercise == %@ AND completed == YES",
            exercise
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutSet.weight, ascending: false)]
        request.fetchLimit = 1
        
        let maxWeightSet = try context.fetch(request).first
        return maxWeightSet?.weight ?? 0
    }
}

// MARK: - Extension for fetching exercise history

extension StatisticsService {
    func getExerciseHistory(for exercise: Exercise, limit: Int = 3) throws -> [ExerciseWorkoutData] {
        let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@ AND workout.date != nil", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutExercise.workout?.date, ascending: false)]
        request.fetchLimit = limit
        
        let workoutExercises = try context.fetch(request)
        
        return workoutExercises.compactMap { workoutExercise in
            guard let workout = workoutExercise.workout,
                  let date = workout.date else { return nil }
            
            let sets = workoutExercise.setsArray
                .filter { $0.completed && $0.weight > 0 && $0.reps > 0 }
                .map { set in
                    let weightInUserUnit = UserPreferences.shared.convertFromStorageUnit(set.weight)
                    
                    return SetData(
                        setNumber: Int(set.setNumber),
                        weight: weightInUserUnit,
                        reps: Int(set.reps),
                        isPersonalRecord: false
                    )
                }
            
            guard !sets.isEmpty else { return nil }
            
            return ExerciseWorkoutData(
                workout: workout,
                date: date,
                sets: sets
            )
        }
    }
}
