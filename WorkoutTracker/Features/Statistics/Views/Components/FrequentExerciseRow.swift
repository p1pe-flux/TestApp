//
//  FrequentExerciseRow.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 7/7/25.
//

import SwiftUI

struct FrequentExerciseRow: View {
    let exerciseData: FrequentExerciseData
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Icono del ejercicio
                Image(systemName: exerciseData.exercise.categoryEnum.systemImage)
                    .font(.title2)
                    .foregroundColor(exerciseData.exercise.categoryEnum.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(exerciseData.exercise.categoryEnum.color.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseData.exercise.wrappedName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: Theme.Spacing.small) {
                        Label("\(exerciseData.timesPerformed)x", systemImage: "repeat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let lastPerformed = exerciseData.lastPerformed {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Label(lastPerformed.relativeString, systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Indicador de tendencia
                if let trend = exerciseData.trend {
                    TrendIndicator(trend: trend)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(Theme.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrendIndicator: View {
    let trend: ExerciseTrend
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: trend.isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
            
            Text("\(abs(trend.percentageChange))%")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(trend.isPositive ? Theme.Colors.success : Theme.Colors.error)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(trend.isPositive ? Theme.Colors.success.opacity(0.1) : Theme.Colors.error.opacity(0.1))
        )
    }
}

// MARK: - Data Models

struct FrequentExerciseData: Identifiable {
    let id = UUID()
    let exercise: Exercise
    let timesPerformed: Int
    let lastPerformed: Date?
    let trend: ExerciseTrend?
}

struct ExerciseTrend {
    let percentageChange: Int
    let isPositive: Bool
}
