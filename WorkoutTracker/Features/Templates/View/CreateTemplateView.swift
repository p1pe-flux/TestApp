//
//  CreateTemplateView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 4/8/25.
//


//
//  CreateTemplateView.swift
//  WorkoutTracker
//
//  Vista para crear un nuevo template
//

import SwiftUI
import CoreData

struct CreateTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var templateName = ""
    @State private var templateNotes = ""
    @State private var selectedExercises: [ExerciseWithSets] = []
    @State private var showingExercisePicker = false
    @State private var isCreating = false
    @FocusState private var isTextFieldFocused: Bool
    
    struct ExerciseWithSets: Identifiable {
        let id = UUID()
        let exercise: Exercise
        var sets: [SetConfiguration] = [
            SetConfiguration(),
            SetConfiguration(),
            SetConfiguration()
        ]
    }
    
    struct SetConfiguration: Identifiable {
        let id = UUID()
        var weight: String = ""
        var reps: String = ""
        var restTime: Int = 90
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Template Details") {
                    TextField("Template Name", text: $templateName)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.words)
                    
                    ZStack(alignment: .topLeading) {
                        if templateNotes.isEmpty {
                            Text("Notes (optional)")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $templateNotes)
                            .frame(minHeight: 60)
                            .focused($isTextFieldFocused)
                    }
                }
                
                Section("Exercises") {
                    if selectedExercises.isEmpty {
                        Button("Add Exercises") {
                            isTextFieldFocused = false
                            showingExercisePicker = true
                        }
                    } else {
                        ForEach($selectedExercises) { $exerciseWithSets in
                            ExerciseTemplateSection(exerciseWithSets: $exerciseWithSets) {
                                selectedExercises.removeAll { $0.id == exerciseWithSets.id }
                            }
                        }
                        
                        Button("Add More Exercises") {
                            isTextFieldFocused = false
                            showingExercisePicker = true
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("New Template")
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
                    Button("Save") {
                        isTextFieldFocused = false
                        saveTemplate()
                    }
                    .disabled(templateName.isEmpty || selectedExercises.isEmpty || isCreating)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(selectedExercises: .init(
                    get: { selectedExercises.map { $0.exercise } },
                    set: { exercises in
                        // Add only new exercises
                        for exercise in exercises {
                            if !selectedExercises.contains(where: { $0.exercise.id == exercise.id }) {
                                selectedExercises.append(ExerciseWithSets(exercise: exercise))
                            }
                        }
                    }
                ))
            }
            .interactiveDismissDisabled(isCreating)
        }
    }
    
    private func saveTemplate() {
        guard !isCreating else { return }
        isCreating = true
        
        let template = WorkoutTemplate(context: context)
        template.id = UUID()
        template.name = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        template.notes = templateNotes.isEmpty ? nil : templateNotes
        template.createdAt = Date()
        template.updatedAt = Date()
        
        for (index, exerciseWithSets) in selectedExercises.enumerated() {
            let templateExercise = TemplateExercise(context: context)
            templateExercise.id = UUID()
            templateExercise.template = template
            templateExercise.exercise = exerciseWithSets.exercise
            templateExercise.order = Int16(index)
            
            var setsConfig: [[String: Any]] = []
            for set in exerciseWithSets.sets {
                let weight = WeightInputFormatter.parseWeight(set.weight) ?? 0
                let weightInKg = UserPreferences.shared.weightUnit.convert(weight, to: .kilograms)
                
                setsConfig.append([
                    "setNumber": setsConfig.count + 1,
                    "weight": weightInKg,
                    "reps": Int(set.reps) ?? 0,
                    "restTime": set.restTime
                ])
            }
            templateExercise.setsConfiguration = try? JSONSerialization.data(withJSONObject: setsConfig)
        }
        
        do {
            try context.save()
            HapticManager.shared.notification(.success)
            dismiss()
        } catch {
            print("Error saving template: \(error)")
            isCreating = false
        }
    }
}

struct ExerciseTemplateSection: View {
    @Binding var exerciseWithSets: CreateTemplateView.ExerciseWithSets
    let onRemove: () -> Void
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Text(exerciseWithSets.exercise.wrappedName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            if isExpanded {
                ForEach($exerciseWithSets.sets) { $set in
                    TemplateSetRow(set: $set, setNumber: exerciseWithSets.sets.firstIndex(where: { $0.id == set.id })! + 1)
                }
                
                Button(action: {
                    exerciseWithSets.sets.append(CreateTemplateView.SetConfiguration())
                }) {
                    Label("Add Set", systemImage: "plus.circle")
                        .font(.caption)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

struct TemplateSetRow: View {
    @Binding var set: CreateTemplateView.SetConfiguration
    let setNumber: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .frame(width: 30, alignment: .center)
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 2) {
                Text("Weight")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $set.weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(6)
                    .onChange(of: set.weight) { _, newValue in
                        set.weight = WeightInputFormatter.sanitizeWeightInput(newValue)
                    }
            }
            
            VStack(spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $set.reps)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(6)
                    .onChange(of: set.reps) { _, newValue in
                        set.reps = newValue.filter { $0.isNumber }
                    }
            }
            
            VStack(spacing: 2) {
                Text("Rest")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(set.restTime)s")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 50)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(6)
            }
        }
    }
}