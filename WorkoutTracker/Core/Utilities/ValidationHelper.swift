//
//  ValidationHelper.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation

struct ValidationHelper {
    static func validateExerciseName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 2 && trimmed.count <= 50
    }
    
    static func validateWorkoutName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 50
    }
    
    static func validateWeight(_ weight: Double) -> Bool {
        return weight >= 0 && weight <= 1000
    }
    
    static func validateReps(_ reps: Int) -> Bool {
        return reps >= 0 && reps <= 1000
    }
    
    static func sanitizeNumericInput(_ input: String, allowDecimal: Bool = false) -> String {
        let allowedCharacters = allowDecimal ? "0123456789." : "0123456789"
        let filtered = input.filter { allowedCharacters.contains($0) }
        
        if allowDecimal {
            let components = filtered.split(separator: ".")
            if components.count > 2 {
                return String(components[0]) + "." + components[1...].joined()
            }
        }
        
        return filtered
    }
}