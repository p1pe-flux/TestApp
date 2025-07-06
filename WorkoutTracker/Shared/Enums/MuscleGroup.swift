//
//  MuscleGroup.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation

enum MuscleGroup: String, CaseIterable {
    // Chest
    case pectoralMajor = "Pectoral Major"
    case pectoralMinor = "Pectoral Minor"
    
    // Back
    case latissimusDorsi = "Latissimus Dorsi"
    case trapezius = "Trapezius"
    case rhomboids = "Rhomboids"
    case erectorSpinae = "Erector Spinae"
    
    // Shoulders
    case anteriorDeltoid = "Anterior Deltoid"
    case medialDeltoid = "Medial Deltoid"
    case posteriorDeltoid = "Posterior Deltoid"
    
    // Arms
    case bicepsBrachii = "Biceps Brachii"
    case tricepsBrachii = "Triceps Brachii"
    case forearms = "Forearms"
    
    // Legs
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case hipFlexors = "Hip Flexors"
    case adductors = "Adductors"
    case abductors = "Abductors"
    
    // Core
    case rectusAbdominis = "Rectus Abdominis"
    case obliques = "Obliques"
    case transverseAbdominis = "Transverse Abdominis"
    
    var category: ExerciseCategory {
        switch self {
        case .pectoralMajor, .pectoralMinor:
            return .chest
        case .latissimusDorsi, .trapezius, .rhomboids, .erectorSpinae:
            return .back
        case .anteriorDeltoid, .medialDeltoid, .posteriorDeltoid:
            return .shoulders
        case .bicepsBrachii:
            return .biceps
        case .tricepsBrachii:
            return .triceps
        case .forearms:
            return .other
        case .quadriceps, .hamstrings, .glutes, .calves, .hipFlexors, .adductors, .abductors:
            return .legs
        case .rectusAbdominis, .obliques, .transverseAbdominis:
            return .core
        }
    }
}