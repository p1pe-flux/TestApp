//
//  CreateWorkoutView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var workoutName = ""
    @State private var workoutDate = Date()
    @State private var workoutNotes = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingExercisePicker = false
    
    private let workoutService: WorkoutService
    
    init() {
        self.workoutService = WorkoutService(context: PersistenceController.shared.container.viewContext)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workout Details") {
                    TextField("Workout Name", text: $workoutName)
                    DatePicker("Date", selection: $workoutDate, displayedComponents: [.date, .hourAndMinute])
                    TextEditor(text: $workoutNotes)
                        .frame(minHeight: 60)
                }
                
                Section("Exercises") {
                    if selectedExercises.isEmpty {
                        Button("Add Exercises") {
                            showingExercisePicker = true
                        }
                    } else {
                        ForEach(selectedExercises) { exercise in
                            Text(exercise.wrappedName)
                        }
                        .onDelete { offsets in
                            selectedExercises.remove(atOffsets: offsets)
                        }
                        
                        Button("Add More") {
                            showingExercisePicker = true
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createWorkout() }
                        .disabled(workoutName.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePicker(selectedExercises: $selectedExercises)
            }
        }
    }
    
    private func createWorkout() {
            Task {
                do {
                    let workout = try workoutService.createWorkout(
                        name: workoutName,
                        date: workoutDate,
                        notes: workoutNotes.isEmpty ? nil : workoutNotes
                    )
                    
                    // Add exercises to workout
                    for (index, exercise) in selectedExercises.enumerated() {
                        let workoutExercise = WorkoutExercise(context: context)
                        workoutExercise.id = UUID()
                        workoutExercise.workout = workout
                        workoutExercise.exercise = exercise
                        workoutExercise.order = Int16(index)
                        
                        // Add some default sets for each exercise
                        for setNumber in 1...3 {
                            let set = WorkoutSet(context: context)
                            set.id = UUID()
                            set.workoutExercise = workoutExercise
                            set.setNumber = Int16(setNumber)
                            set.restTime = Int16(UserPreferences.shared.defaultRestTime)
                            set.createdAt = Date()
                        }
                    }
                    
                    try context.save()
                    
                    // Trigger notification to refresh lists
                    NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: context)
                    
                    dismiss()
                } catch {
                    print("Error creating workout: \(error)")
                }
            }
        }
}

struct ExercisePicker: View {
    @Binding var selectedExercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
    ) private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(exercises) { exercise in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.wrappedName)
                            Text(exercise.wrappedCategory)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedExercises.contains(where: { $0.id == exercise.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                            selectedExercises.remove(at: index)
                        } else {
                            selectedExercises.append(exercise)
                        }
                    }
                }
            }
            .navigationTitle("Select Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
