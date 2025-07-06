//
//  Theme.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct Theme {
    struct Colors {
        static let primary = Color.accentColor
        static let secondary = Color.secondary
        
        // Exercise categories
        static let chest = Color(red: 0.96, green: 0.26, blue: 0.21)
        static let back = Color(red: 0.13, green: 0.59, blue: 0.95)
        static let shoulders = Color(red: 1.0, green: 0.60, blue: 0.0)
        static let biceps = Color(red: 0.55, green: 0.76, blue: 0.29)
        static let triceps = Color(red: 0.61, green: 0.15, blue: 0.69)
        static let legs = Color(red: 0.0, green: 0.74, blue: 0.83)
        static let core = Color(red: 1.0, green: 0.76, blue: 0.03)
        static let cardio = Color(red: 0.96, green: 0.26, blue: 0.21)
        static let other = Color.gray
        
        // Status
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
    }
    
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
    }
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primary, Colors.primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}