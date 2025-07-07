//
//  CreateWorkoutFromCalendarView.swift
//  WorkoutTracker
//
//  Vista para crear workouts desde el calendario
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
    @State private var isCreating = false
    @State private var showingRecentWorkouts = false
    
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
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.medium) {
                        switch creationMethod {
                        case .blank:
                            blankWorkoutForm
                        case .template:
                            templateSelectionSection
                        case .duplicate:
                            recentWorkoutsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreating)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createWorkout) {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(!canCreateWorkout || isCreating)
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePicker(selectedExercises: $selectedExercises)
            }
            .sheet(isPresented: $showingTemplatePicker) {
                TemplateListView { template in
                    selectedTemplate = template
                    workoutName = template.wrappedName
                    showingTemplatePicker = false
                }
            }
            .sheet(isPresented: $showingRecentWorkouts) {
                RecentWorkoutsList { workout in
                    showingRecentWorkouts = false
                    duplicateWorkout(workout)
                }
            }
        }
        .onAppear {
            setupDefaultWorkoutName()
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
        .onChange(of: creationMethod) { _, newMethod in
            resetForm()
        }
    }
    
    private var blankWorkoutForm: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            // Workout Details Section
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text("Workout Details")
                    .font(.headline)
                
                VStack(spacing: Theme.Spacing.small) {
                    CustomTextField(title: "Workout Name", text: $workoutName)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $workoutNotes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                    }
                }
            }
            .cardStyle()
            
            // Exercises Section
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text("Exercises")
                    .font(.headline)
                
                if selectedExercises.isEmpty {
                    Button(action: { showingExercisePicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Theme.Colors.primary)
                            
                            Text("Add Exercises")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                } else {
                    VStack(spacing: Theme.Spacing.xSmall) {
                        ForEach(selectedExercises) { exercise in
                            ExerciseSelectionRow(exercise: exercise) {
                                selectedExercises.removeAll { $0.id == exercise.id }
                            }
                        }
                        
                        Button(action: { showingExercisePicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Theme.Colors.primary)
                                Text("Add More Exercises")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.top, Theme.Spacing.xSmall)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
            .cardStyle()
        }
    }
    
    private var templateSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Select Template")
                .font(.headline)
            
            if let template = selectedTemplate {
                TemplateSelectedCard(template: template) {
                    selectedTemplate = nil
                    workoutName = ""
                }
            } else {
                Button(action: { showingTemplatePicker = true }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Choose Template")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
        }
        .cardStyle()
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Duplicate Recent Workout")
                .font(.headline)
            
            Button(action: { showingRecentWorkouts = true }) {
                HStack {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Theme.Colors.primary)
                    
                    Text("Choose from Recent Workouts")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(Theme.CornerRadius.small)
            }
            
            Text("Select a recent workout to duplicate it for this date.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .cardStyle()
    }
    
    private var canCreateWorkout: Bool {
        switch creationMethod {
        case .blank:
            return !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .template:
            return selectedTemplate != nil && !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .duplicate:
            return false // Se crea directamente desde la selección
        }
    }
    
    private func setupDefaultWorkoutName() {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(selectedDate) {
            workoutName = "Today's Workout"
        } else if calendar.isDateInTomorrow(selectedDate) {
            workoutName = "Tomorrow's Workout"
        } else {
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: selectedDate)
            workoutName = "\(dayName) Workout"
        }
    }
    
    private func resetForm() {
        setupDefaultWorkoutName()
        selectedTemplate = nil
        selectedExercises = []
        workoutNotes = ""
    }
    
    private func createWorkout() {
        guard !isCreating else { return }
        isCreating = true
        
        Task {
            do {
                switch creationMethod {
                case .blank:
                    let workout = try workoutService.createWorkout(
                        name: workoutName.trimmingCharacters(in: .whitespacesAndNewlines),
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
                        
                        // Add default sets
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
                    
                case .template:
                    if let template = selectedTemplate {
                        _ = try duplicationService.createWorkout(
                            from: template,
                            date: selectedDate,
                            name: workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                    
                case .duplicate:
                    break // Se maneja en duplicateWorkout
                }
                
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                print("Error creating workout: \(error)")
                isCreating = false
            }
        }
    }
    
    private func duplicateWorkout(_ workout: Workout) {
        isCreating = true
        
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
                isCreating = false
            }
        }
    }
}

// MARK: - Supporting Views

struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.wrappedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TemplateSelectedCard: View {
    let template: WorkoutTemplate
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.wrappedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(template.exercisesArray.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Theme.Colors.primary.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.small)
    }
}
