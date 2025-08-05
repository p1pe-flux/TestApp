//
//  WorkoutExercise+Extensions.swift
//  WorkoutTracker
//
//  Extensiones para WorkoutExercise, WorkoutSet y WorkoutTemplate
//

import Foundation
import CoreData

// MARK: - WorkoutExercise Extensions
extension WorkoutExercise {
    var setsArray: [WorkoutSet] {
        let set = self.value(forKey: "sets") as? Set<WorkoutSet> ?? []
        return set.sorted { $0.setNumber < $1.setNumber }
    }
    
    var completedSetsCount: Int {
        setsArray.filter { $0.completed }.count
    }
    
    var totalVolume: Double {
        setsArray.reduce(0) { $0 + $1.volume }
    }
}

// MARK: - WorkoutSet Extensions
extension WorkoutSet {
    var volume: Double {
        weight * Double(reps)
    }
    
    var formattedWeight: String {
        // Convert from storage unit to user's preferred unit
        let convertedWeight = UserPreferences.shared.convertFromStorageUnit(weight)
        return WeightInputFormatter.formatWeight(convertedWeight)
    }
    
    var displayWeight: String {
        let convertedWeight = UserPreferences.shared.convertFromStorageUnit(weight)
        return UserPreferences.shared.formatWeight(convertedWeight)
    }
}

// MARK: - WorkoutTemplate Extensions
extension WorkoutTemplate {
    var wrappedName: String {
        self.value(forKey: "name") as? String ?? "Unnamed Template"
    }
    
    var exercisesArray: [TemplateExercise] {
        let set = self.value(forKey: "templateExercises") as? Set<TemplateExercise> ?? []
        return set.sorted { $0.order < $1.order }
    }
}
