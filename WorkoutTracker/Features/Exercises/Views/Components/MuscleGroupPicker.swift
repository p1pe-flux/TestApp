//
//  MuscleGroupPicker.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct MuscleGroupPicker: View {
    @Binding var selectedMuscleGroups: Set<MuscleGroup>
    @Environment(\.dismiss) private var dismiss
    
    private var groupedMuscleGroups: [(category: ExerciseCategory, muscles: [MuscleGroup])] {
        let grouped = Dictionary(grouping: MuscleGroup.allCases) { $0.category }
        return grouped
            .map { (category: $0.key, muscles: $0.value) }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedMuscleGroups, id: \.category) { group in
                    Section(group.category.rawValue) {
                        ForEach(group.muscles, id: \.self) { muscle in
                            HStack {
                                Text(muscle.rawValue)
                                Spacer()
                                if selectedMuscleGroups.contains(muscle) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedMuscleGroups.contains(muscle) {
                                    selectedMuscleGroups.remove(muscle)
                                } else {
                                    selectedMuscleGroups.insert(muscle)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Muscle Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}