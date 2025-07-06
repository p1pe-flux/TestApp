//
//  ExerciseRow.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.wrappedName)
                .font(.headline)
            
            HStack {
                Label(exercise.wrappedCategory, systemImage: exercise.categoryEnum.systemImage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !exercise.muscleGroupsArray.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(exercise.muscleGroupsArray.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}