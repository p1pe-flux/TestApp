//
//  Notification+Extensions.swift
//  WorkoutTracker
//
//  Extensiones para nombres de notificaciones
//

import Foundation

extension Notification.Name {
    static let workoutCreated = Notification.Name("workoutCreated")
    static let workoutUpdated = Notification.Name("workoutUpdated")
    static let workoutDeleted = Notification.Name("workoutDeleted")
    
    static let exerciseCreated = Notification.Name("exerciseCreated")
    static let exerciseUpdated = Notification.Name("exerciseUpdated")
    static let exerciseDeleted = Notification.Name("exerciseDeleted")
}
