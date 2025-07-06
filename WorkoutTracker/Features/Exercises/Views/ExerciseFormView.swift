//
//  ExerciseFormView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct ExerciseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var name = ""
    @State private var category = ExerciseCategory.other
    @State private var selectedMuscleGroups = Set<MuscleGroup>()
    @State private var notes = ""
    @State private var showingMuscleGroupPicker = false
    
    let exercise: Exercise?
    private let exerciseService: ExerciseService
    
    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        self.exerciseService = ExerciseService(context: PersistenceController.shared.container.viewContext)
        
        if let exercise = exercise {
            _name = State(initialValue: exercise.wrappedName)
            _category = State(initialValue: exercise.categoryEnum)
            _selectedMuscleGroups = State(initialValue: Set(exercise.muscleGroupsArray.compactMap { MuscleGroup(rawValue: $0) }))
            _notes = State(initialValue: exercise.wrappedNotes)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Name") {
                    TextField("Enter name", text: $name)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                }
                
                Section("Muscle Groups") {
                    if selectedMuscleGroups.isEmpty {
                        Button("Select muscle groups") {
                            showingMuscleGroupPicker = true
                        }
                    } else {
                        ForEach(Array(selectedMuscleGroups), id: \.self) { muscle in
                            HStack {
                                Text(muscle.rawValue)
                                Spacer()
                                Button(action: { selectedMuscleGroups.remove(muscle) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Button("Add more") {
                            showingMuscleGroupPicker = true
                        }
                        .font(.caption)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveExercise() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingMuscleGroupPicker) {
                MuscleGroupPicker(selectedMuscleGroups: $selectedMuscleGroups)
            }
        }
    }
    
    private func saveExercise() {
        Task {
            do {
                if let exercise = exercise {
                    exercise.name = name
                    exercise.category = category.rawValue
                    exercise.muscleGroupsArray = Array(selectedMuscleGroups).map { $0.rawValue }
                    exercise.notes = notes.isEmpty ? nil : notes
                    try exerciseService.updateExercise(exercise)
                } else {
                    _ = try exerciseService.createExercise(
                        name: name,
                        category: category.rawValue,
                        muscleGroups: Array(selectedMuscleGroups).map { $0.rawValue },
                        notes: notes.isEmpty ? nil : notes
                    )
                }
                dismiss()
            } catch {
                print("Error saving exercise: \(error)")
            }
        }
    }
}