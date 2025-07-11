//
//  StatisticsService.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData

class StatisticsService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getWorkoutStats(from startDate: Date? = nil, to endDate: Date? = nil) throws -> WorkoutStatistics {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        if let startDate = startDate, let endDate = endDate {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        }
        
        let workouts = try context.fetch(request)
        
        let totalWorkouts = workouts.count
        let totalVolume = workouts.reduce(0) { $0 + $1.totalVolume }
        let totalSets = workouts.reduce(0) { $0 + $1.totalSets }
        let totalDuration = workouts.reduce(0) { $0 + TimeInterval($1.duration) }
        let averageDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        
        return WorkoutStatistics(
            totalWorkouts: totalWorkouts,
            totalVolume: totalVolume,
            totalSets: totalSets,
            totalDuration: totalDuration,
            averageDuration: averageDuration
        )
    }
    
    func getExerciseStats(for exercise: Exercise, from startDate: Date? = nil) throws -> ExerciseStatistics {
        let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        
        let workoutExercises = try context.fetch(request)
        
        var totalSets = 0
        var totalReps = 0
        var totalVolume: Double = 0
        var maxWeight: Double = 0
        
        for workoutExercise in workoutExercises {
            for set in workoutExercise.setsArray where set.completed {
                totalSets += 1
                totalReps += Int(set.reps)
                totalVolume += set.volume
                maxWeight = max(maxWeight, set.weight)
            }
        }
        
        return ExerciseStatistics(
            exercise: exercise,
            totalSets: totalSets,
            totalReps: totalReps,
            totalVolume: totalVolume,
            maxWeight: maxWeight
        )
    }
}

struct WorkoutStatistics {
    let totalWorkouts: Int
    let totalVolume: Double
    let totalSets: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
}

struct ExerciseStatistics {
    let exercise: Exercise
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Double
    let maxWeight: Double
}