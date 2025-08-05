//
//  UserPreferences.swift
//  WorkoutTracker
//
//  Maneja las preferencias del usuario incluyendo unidades de peso
//

import SwiftUI

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @AppStorage("userName") var userName: String = ""
    @AppStorage("weightUnit") var weightUnit: WeightUnit = .kilograms
    @AppStorage("defaultRestTime") var defaultRestTime: Int = 90
    @AppStorage("autoStartRestTimer") var autoStartRestTimer: Bool = false
    @AppStorage("playTimerSound") var playTimerSound: Bool = true
    @AppStorage("enableHaptics") var enableHaptics: Bool = true
    @AppStorage("appTheme") var appTheme: AppTheme = .system
    
    enum WeightUnit: String, CaseIterable {
        case kilograms = "kg"
        case pounds = "lbs"
        
        func convert(_ value: Double, to unit: WeightUnit) -> Double {
            if self == unit { return value }
            
            switch (self, unit) {
            case (.kilograms, .pounds):
                return value * 2.20462
            case (.pounds, .kilograms):
                return value / 2.20462
            default:
                return value
            }
        }
    }
    
    enum AppTheme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) \(weightUnit.rawValue)"
        } else {
            return String(format: "%.1f %@", weight, weightUnit.rawValue)
        }
    }
    
    func convertWeight(_ weight: Double, from unit: WeightUnit) -> Double {
        return unit.convert(weight, to: weightUnit)
    }
    
    // Convenience method for converting from storage unit (kg) to user preference
    func convertFromStorageUnit(_ weight: Double) -> Double {
        return WeightUnit.kilograms.convert(weight, to: weightUnit)
    }
}
