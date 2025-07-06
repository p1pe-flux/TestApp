//
//  WorkoutCard.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct WorkoutCard: View {
    let workout: Workout
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                HStack {
                    Text(workout.wrappedName)
                        .font(.headline)
                    
                    Spacer()
                    
                    if workout.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.Colors.success)
                    } else if workout.totalSets > 0 {
                        ProgressIndicator(progress: workout.progress)
                            .frame(width: 24, height: 24)
                    }
                }
                
                HStack {
                    Label("\(workout.workoutExercisesArray.count) exercises", systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if workout.duration > 0 {
                        Label(workout.formattedDuration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let date = workout.date {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.Colors.primary, lineWidth: 3)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}