//
//  Workout+Extensions.swift
//  WorkoutTracker
//
//  Extensiones para la entidad Workout de Core Data
//

import Foundation
import CoreData

extension Workout {
    var wrappedName: String {
        return self.value(forKey: "name") as? String ?? "Unnamed Workout"
    }
    
    var wrappedNotes: String {
        return self.value(forKey: "notes") as? String ?? ""
    }
    
    var workoutExercisesArray: [WorkoutExercise] {
        let set = self.value(forKey: "workoutExercises") as? Set<WorkoutExercise> ?? []
        return set.sorted { $0.order < $1.order }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let workoutDate = self.value(forKey: "date") as? Date ?? Date()
        return formatter.string(from: workoutDate)
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(self.value(forKey: "duration") as? Int32 ?? 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var totalSets: Int {
        workoutExercisesArray.reduce(0) { $0 + $1.setsArray.count }
    }
    
    var completedSets: Int {
        workoutExercisesArray.reduce(0) { $0 + $1.setsArray.filter { $0.completed }.count }
    }
    
    var progress: Double {
        guard totalSets > 0 else { return 0 }
        return Double(completedSets) / Double(totalSets)
    }
    
    var isCompleted: Bool {
        totalSets > 0 && completedSets == totalSets
    }
    
    var totalVolume: Double {
        workoutExercisesArray.reduce(into: 0.0) { result, workoutExercise in
            result += workoutExercise.totalVolume
        }
    }
}
