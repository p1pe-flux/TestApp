//
//  WorkoutDuplicationService.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData

class WorkoutDuplicationService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Duplicate Workout
    
    func duplicateWorkout(_ workout: Workout, toDate newDate: Date, withName newName: String? = nil) throws -> Workout {
        let newWorkout = Workout(context: context)
        newWorkout.id = UUID()
        newWorkout.name = newName ?? "\(workout.wrappedName) (Copy)"
        newWorkout.date = newDate
        newWorkout.notes = workout.notes
        newWorkout.createdAt = Date()
        newWorkout.updatedAt = Date()
        newWorkout.duration = 0
        
        // Copy all exercises
        for (index, workoutExercise) in workout.workoutExercisesArray.enumerated() {
            guard let exercise = workoutExercise.exercise else { continue }
            
            let newWorkoutExercise = WorkoutExercise(context: context)
            newWorkoutExercise.id = UUID()
            newWorkoutExercise.workout = newWorkout
            newWorkoutExercise.exercise = exercise
            newWorkoutExercise.order = Int16(index)
            
            // Copy sets but reset completion status
            for set in workoutExercise.setsArray {
                let newSet = WorkoutSet(context: context)
                newSet.id = UUID()
                newSet.workoutExercise = newWorkoutExercise
                newSet.setNumber = set.setNumber
                newSet.weight = set.weight
                newSet.reps = set.reps
                newSet.restTime = set.restTime
                newSet.completed = false
                newSet.createdAt = Date()
            }
        }
        
        try context.save()
        return newWorkout
    }
    
    // MARK: - Template Management
    
    func createTemplate(from workout: Workout, templateName: String) throws -> WorkoutTemplate {
        let template = WorkoutTemplate(context: context)
        template.id = UUID()
        template.name = templateName
        template.notes = workout.notes
        template.createdAt = Date()
        template.updatedAt = Date()
        
        for (index, workoutExercise) in workout.workoutExercisesArray.enumerated() {
            guard let exercise = workoutExercise.exercise else { continue }
            
            let templateExercise = TemplateExercise(context: context)
            templateExercise.id = UUID()
            templateExercise.template = template
            templateExercise.exercise = exercise
            templateExercise.order = Int16(index)
            
            var setsConfig: [[String: Any]] = []
            for set in workoutExercise.setsArray {
                setsConfig.append([
                    "setNumber": set.setNumber,
                    "weight": set.weight,
                    "reps": set.reps,
                    "restTime": set.restTime
                ])
            }
            templateExercise.setsConfiguration = try? JSONSerialization.data(withJSONObject: setsConfig)
        }
        
        try context.save()
        return template
    }
    
    func createWorkout(from template: WorkoutTemplate, date: Date, name: String? = nil) throws -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.name = name ?? template.wrappedName
        workout.date = date
        workout.notes = template.notes
        workout.createdAt = Date()
        workout.updatedAt = Date()
        
        for templateExercise in template.exercisesArray {
            guard let exercise = templateExercise.exercise else { continue }
            
            let workoutExercise = WorkoutExercise(context: context)
            workoutExercise.id = UUID()
            workoutExercise.workout = workout
            workoutExercise.exercise = exercise
            workoutExercise.order = templateExercise.order
            
            if let setsData = templateExercise.setsConfiguration,
               let setsConfig = try? JSONSerialization.jsonObject(with: setsData) as? [[String: Any]] {
                
                for setConfig in setsConfig {
                    let set = WorkoutSet(context: context)
                    set.id = UUID()
                    set.workoutExercise = workoutExercise
                    set.setNumber = setConfig["setNumber"] as? Int16 ?? 1
                    set.weight = setConfig["weight"] as? Double ?? 0
                    set.reps = setConfig["reps"] as? Int16 ?? 0
                    set.restTime = setConfig["restTime"] as? Int16 ?? 90
                    set.completed = false
                    set.createdAt = Date()
                }
            }
        }
        
        try context.save()
        return workout
    }
}