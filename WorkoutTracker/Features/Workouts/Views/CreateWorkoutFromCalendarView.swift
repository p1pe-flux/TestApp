//
//  CreateWorkoutFromCalendarView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI
import CoreData

struct CreateWorkoutFromCalendarView: View {
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var workoutName = ""
    @State private var workoutNotes = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingExercisePicker = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingTemplatePicker = false
    @State private var creationMethod: CreationMethod = .blank
    
    private let workoutService: WorkoutService
    private let duplicationService: WorkoutDuplicationService
    
    enum CreationMethod: String, CaseIterable {
        case blank = "Start from Blank"
        case template = "Use Template"
        case duplicate = "Duplicate Recent"
        
        var icon: String {
            switch self {
            case .blank: return "doc.badge.plus"
            case .template: return "doc.text"
            case .duplicate: return "doc.on.doc"
            }
        }
    }
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        let context = PersistenceController.shared.container.viewContext
        self.workoutService = WorkoutService(context: context)
        self.duplicationService = WorkoutDuplicationService(context: context)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                dateHeader
                creationMethodSelector
                
                Group {
                    switch creationMethod {
                    case .blank:
                        blankWorkoutForm
                    case .template:
                        templateSelectionView
                    case .duplicate:
                        recentWorkoutsView
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
                        .disabled(!canCreateWorkout)
                        .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePicker(selectedExercises: $selectedExercises)
            }
        }
    }
    
    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Scheduled for")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(selectedDate.formatted(date: .complete, time: .omitted))
                    .font(.headline)
            }
            
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.title2)
                .foregroundColor(Theme.Colors.primary)
        }
        .padding()
        .background(Theme.Colors.primary.opacity(0.1))
    }
    
    private var creationMethodSelector: some View {
        Picker("Creation Method", selection: $creationMethod) {
            ForEach(CreationMethod.allCases, id: \.self) { method in
                Label(method.rawValue, systemImage: method.icon)
                    .tag(method)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var blankWorkoutForm: some View {
        Form {
            Section(header: Text("Workout Details")) {
                TextField("Workout Name", text: $workoutName)
                    .autocapitalization(.words)
                
                TextEditor(text: $workoutNotes)
                    .frame(minHeight: 60)
            }
            
            Section(header: Text("Exercises")) {
                if selectedExercises.isEmpty {
                    Button(action: { showingExercisePicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                            Text("Add Exercises")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                } else {
                    ForEach(selectedExercises) { exercise in
                        Text(exercise.wrappedName)
                    }
                    .onDelete { offsets in
                        selectedExercises.remove(atOffsets: offsets)
                    }
                    
                    Button(action: { showingExercisePicker = true }) {
                        Label("Add More", systemImage: "plus.circle")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private var templateSelectionView: some View {
        TemplateListView(onSelectTemplate: { template in
            selectedTemplate = template
            workoutName = template.wrappedName
        })
    }
    
    private var recentWorkoutsView: some View {
        RecentWorkoutsList(onSelectWorkout: { workout in
            duplicateWorkout(workout)
        })
    }
    
    private var canCreateWorkout: Bool {
        switch creationMethod {
        case .blank:
            return !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .template:
            return selectedTemplate != nil
        case .duplicate:
            return false
        }
    }
    
    private func createWorkout() {
        Task {
            do {
                switch creationMethod {
                case .blank:
                    let workout = try workoutService.createWorkout(
                        name: workoutName,
                        date: selectedDate,
                        notes: workoutNotes.isEmpty ? nil : workoutNotes
                    )
                    
                    // Add exercises
                    for (index, exercise) in selectedExercises.enumerated() {
                        let workoutExercise = WorkoutExercise(context: context)
                        workoutExercise.id = UUID()
                        workoutExercise.workout = workout
                        workoutExercise.exercise = exercise
                        workoutExercise.order = Int16(index)
                    }
                    
                    try context.save()
                    
                case .template:
                    if let template = selectedTemplate {
                        _ = try duplicationService.createWorkout(
                            from: template,
                            date: selectedDate,
                            name: workoutName
                        )
                    }
                    
                case .duplicate:
                    break
                }
                
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                print("Error creating workout: \(error)")
            }
        }
    }
    
    private func duplicateWorkout(_ workout: Workout) {
        Task {
            do {
                _ = try duplicationService.duplicateWorkout(
                    workout,
                    toDate: selectedDate
                )
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                print("Error duplicating workout: \(error)")
            }
        }
    }
}