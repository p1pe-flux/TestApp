//
//  WorkoutListViewModel.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class WorkoutListViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var todayWorkouts: [Workout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let workoutService: WorkoutServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutService: WorkoutServiceProtocol) {
        self.workoutService = workoutService
        loadWorkouts()
        
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        self?.loadWorkouts()
                    }
                    .store(in: &cancellables)
    }
    
    func loadWorkouts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                workouts = try workoutService.fetchAllWorkouts()
                todayWorkouts = try workoutService.fetchTodayWorkouts()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func createWorkout(name: String, date: Date = Date(), notes: String? = nil) async {
        do {
            _ = try workoutService.createWorkout(name: name, date: date, notes: notes)
            loadWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteWorkout(_ workout: Workout) async {
        do {
            try workoutService.deleteWorkout(workout)
            loadWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
