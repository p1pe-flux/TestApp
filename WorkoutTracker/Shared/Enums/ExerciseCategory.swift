//
//  ExerciseCategory.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

enum ExerciseCategory: String, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .chest, .back, .shoulders: return "figure.strengthtraining.traditional"
        case .biceps, .triceps: return "figure.arms.open"
        case .legs: return "figure.walk"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        case .other: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .chest: return Theme.Colors.chest
        case .back: return Theme.Colors.back
        case .shoulders: return Theme.Colors.shoulders
        case .biceps: return Theme.Colors.biceps
        case .triceps: return Theme.Colors.triceps
        case .legs: return Theme.Colors.legs
        case .core: return Theme.Colors.core
        case .cardio: return Theme.Colors.cardio
        case .other: return Theme.Colors.other
        }
    }
}