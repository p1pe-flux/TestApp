//
//  CreateWorkoutView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI
import CoreData

struct CreateWorkoutView: View {
    let selectedDate: Date?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var workoutName = ""
    @State private var workoutDate = Date()
    @State private var workoutNotes = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingExercisePicker = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingTemplatePicker = false
    @State private var creationMethod: CreationMethod = .blank
    @State private var isCreating = false
    @State private var showingRecentWorkouts = false
    @FocusState private var isTextFieldFocused: Bool
    
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
    
    init(selectedDate: Date? = nil) {
        self.selectedDate = selectedDate
        let context = PersistenceController.shared.container.viewContext
        self.workoutService = WorkoutService(context: context)
        self.duplicationService = WorkoutDuplicationService(context: context)
        _workoutDate = State(initialValue: selectedDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if selectedDate != nil {
                    dateHeader
                }
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
                        isTextFieldFocused = false
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
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(selectedExercises: $selectedExercises)
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
            .interactiveDismissDisabled(isCreating)
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
                
                Text(workoutDate.formatted(date: .complete, time: .omitted))
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
                        .focused($isTextFieldFocused)
                    
                    if selectedDate == nil {
                        DatePicker("Date", selection: $workoutDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if workoutNotes.isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $workoutNotes)
                                .frame(minHeight: 80)
                                .padding(4)
                                .focused($isTextFieldFocused)
                        }
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
                    Button(action: {
                        isTextFieldFocused = false
                        showingExercisePicker = true
                    }) {
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
                        
                        Button(action: {
                            isTextFieldFocused = false
                            showingExercisePicker = true
                        }) {
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
                Button(action: {
                    isTextFieldFocused = false
                    showingTemplatePicker = true
                }) {
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
            
            if selectedTemplate != nil {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Customize")
                        .font(.headline)
                        .padding(.top)
                    
                    CustomTextField(title: "Workout Name", text: $workoutName)
                        .focused($isTextFieldFocused)
                }
            }
        }
        .cardStyle()
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Duplicate Recent Workout")
                .font(.headline)
            
            Button(action: {
                isTextFieldFocused = false
                showingRecentWorkouts = true
            }) {
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
            
            Text("Select a recent workout to duplicate it for \(workoutDate.formatted(date: .abbreviated, time: .omitted)).")
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
            return false
        }
    }
    
    private func setupDefaultWorkoutName() {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(workoutDate) {
            workoutName = "Today's Workout"
        } else if calendar.isDateInTomorrow(workoutDate) {
            workoutName = "Tomorrow's Workout"
        } else {
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: workoutDate)
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
                        date: workoutDate,
                        notes: workoutNotes.isEmpty ? nil : workoutNotes
                    )
                    
                    for (index, exercise) in selectedExercises.enumerated() {
                        let workoutExercise = WorkoutExercise(context: context)
                        workoutExercise.id = UUID()
                        workoutExercise.workout = workout
                        workoutExercise.exercise = exercise
                        workoutExercise.order = Int16(index)
                        
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
                            date: workoutDate,
                            name: workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                    
                case .duplicate:
                    break
                }
                
                HapticManager.shared.notification(.success)
                
                await MainActor.run {
                    dismiss()
                }
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
                    toDate: workoutDate
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

struct ExercisePickerView: View {
    @Binding var selectedExercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
    ) private var exercises: FetchedResults<Exercise>
    
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return Array(exercises)
        } else {
            return exercises.filter { exercise in
                exercise.wrappedName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                List {
                    ForEach(filteredExercises) { exercise in
                        ExercisePickerRow(
                            exercise: exercise,
                            isSelected: selectedExercises.contains(where: { $0.id == exercise.id })
                        ) {
                            if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                selectedExercises.remove(at: index)
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
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

struct ExercisePickerRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.wrappedName)
                    .foregroundColor(.primary)
                Text(exercise.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search exercises...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
