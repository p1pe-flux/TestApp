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
    
    static func validateWeightString(_ weightStr: String) -> Bool {
        guard let weight = WeightInputFormatter.parseWeight(weightStr) else {
            return weightStr.isEmpty // Permitir campo vacío
        }
        return validateWeight(weight)
    }
    
    static func validateReps(_ reps: Int) -> Bool {
        return reps >= 0 && reps <= 1000
    }
    
    static func sanitizeNumericInput(_ input: String, allowDecimal: Bool = false) -> String {
        if allowDecimal {
            return WeightInputFormatter.sanitizeWeightInput(input)
        } else {
            // Solo números para reps
            return input.filter { "0123456789".contains($0) }
        }
    }
}
