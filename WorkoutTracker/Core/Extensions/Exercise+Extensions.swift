//
//  Exercise+Extensions.swift
//  WorkoutTracker
//
//  Extensiones para la entidad Exercise de Core Data
//

import Foundation

extension Exercise {
    var wrappedName: String {
        name ?? "Unknown Exercise"
    }
    
    var wrappedCategory: String {
        category ?? ExerciseCategory.other.rawValue
    }
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var muscleGroupsArray: [String] {
        get {
            if let array = muscleGroups as? [String] {
                return array
            } else if let array = muscleGroups as? NSArray as? [String] {
                return array
            }
            return []
        }
        set {
            muscleGroups = NSArray(array: newValue)
        }
    }
    
    var categoryEnum: ExerciseCategory {
        ExerciseCategory(rawValue: wrappedCategory) ?? .other
    }
}
