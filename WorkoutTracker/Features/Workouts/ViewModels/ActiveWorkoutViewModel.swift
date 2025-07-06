//
//  ActiveWorkoutViewModel.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class ActiveWorkoutViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var workoutExercises: [WorkoutExercise] = []
    @Published var elapsedTime: TimeInterval = 0
    @Published var isTimerRunning = false
    @Published var restTimerSeconds = 0
    @Published var isRestTimerRunning = false
    
    private let workoutService: WorkoutService
    private var timer: Timer?
    private var restTimer: Timer?
    private var startTime: Date?
    
    init(workout: Workout, workoutService: WorkoutService) {
        self.workout = workout
        self.workoutService = workoutService
        self.workoutExercises = workout.workoutExercisesArray
    }
    
    func startWorkout() {
        startTime = Date()
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func pauseWorkout() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeWorkout() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func endWorkout() {
        pauseWorkout()
        Task {
            do {
                try workoutService.endWorkout(workout, duration: elapsedTime)
            } catch {
                print("Error ending workout: \(error)")
            }
        }
    }
    
    func startRestTimer(seconds: Int) {
        restTimerSeconds = seconds
        isRestTimerRunning = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateRestTimer()
        }
    }
    
    func stopRestTimer() {
        isRestTimerRunning = false
        restTimer?.invalidate()
        restTimer = nil
        restTimerSeconds = 0
    }
    
    func addSet(to workoutExercise: WorkoutExercise) {
        guard let context = workoutExercise.managedObjectContext else { return }
        
        let newSet = WorkoutSet(context: context)
        newSet.id = UUID()
        newSet.setNumber = Int16(workoutExercise.setsArray.count + 1)
        newSet.createdAt = Date()
        newSet.restTime = Int16(UserPreferences.shared.defaultRestTime)
        
        workoutExercise.addToSets(newSet)
        
        do {
            try context.save()
            workoutExercises = workout.workoutExercisesArray
        } catch {
            print("Error adding set: \(error)")
        }
    }
    
    func updateSet(_ set: WorkoutSet, weight: Double, reps: Int16, completed: Bool) {
        set.weight = weight
        set.reps = reps
        set.completed = completed
        
        do {
            try set.managedObjectContext?.save()
            
            if completed && UserPreferences.shared.autoStartRestTimer {
                startRestTimer(seconds: Int(set.restTime))
            }
        } catch {
            print("Error updating set: \(error)")
        }
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    private func updateRestTimer() {
        if restTimerSeconds > 0 {
            restTimerSeconds -= 1
        } else {
            stopRestTimer()
            if UserPreferences.shared.playTimerSound {
                HapticManager.shared.notification(.success)
            }
        }
    }
}