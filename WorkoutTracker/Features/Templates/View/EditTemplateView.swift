//
//  EditTemplateView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 4/8/25.
//


//
//  EditTemplateView.swift
//  WorkoutTracker
//
//  Vista para editar un template existente
//

import SwiftUI
import CoreData

struct EditTemplateView: View {
    let template: WorkoutTemplate
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var templateName = ""
    @State private var templateNotes = ""
    @State private var isUpdating = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                    ForEach(template.exercisesArray) { templateExercise in
                        if let exercise = templateExercise.exercise {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.wrappedName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if let setsData = templateExercise.setsConfiguration,
                                   let setsConfig = try? JSONSerialization.jsonObject(with: setsData) as? [[String: Any]] {
                                    Text("\(setsConfig.count) sets configured")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        deleteTemplate()
                    } label: {
                        Label("Delete Template", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isTextFieldFocused = false
                        dismiss()
                    }
                    .disabled(isUpdating)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        isTextFieldFocused = false
                        updateTemplate()
                    }
                    .disabled(templateName.isEmpty || isUpdating)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
            .onAppear {
                templateName = template.wrappedName
                templateNotes = template.notes ?? ""
            }
        }
    }
    
    private func updateTemplate() {
        guard !isUpdating else { return }
        isUpdating = true
        
        template.name = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        template.notes = templateNotes.isEmpty ? nil : templateNotes
        template.updatedAt = Date()
        
        do {
            try context.save()
            HapticManager.shared.notification(.success)
            dismiss()
        } catch {
            print("Error updating template: \(error)")
            isUpdating = false
        }
    }
    
    private func deleteTemplate() {
        context.delete(template)
        
        do {
            try context.save()
            HapticManager.shared.notification(.success)
            dismiss()
        } catch {
            print("Error deleting template: \(error)")
        }
    }
}