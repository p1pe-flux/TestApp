//
//  TemplateManagerView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 4/8/25.
//


//
//  TemplateManagerView.swift
//  WorkoutTracker
//
//  Vista para gestionar templates de workout
//

import SwiftUI
import CoreData

struct TemplateManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: WorkoutTemplate.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutTemplate.createdAt, ascending: false)]
    ) private var templates: FetchedResults<WorkoutTemplate>
    
    @State private var showingCreateTemplate = false
    @State private var templateToEdit: WorkoutTemplate?
    
    var body: some View {
        NavigationView {
            Group {
                if templates.isEmpty {
                    emptyState
                } else {
                    templateList
                }
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTemplate = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateTemplateView()
            }
            .sheet(item: $templateToEdit) { template in
                EditTemplateView(template: template)
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "doc.text",
            title: "No Templates",
            message: "Create templates from completed workouts or build custom ones",
            actionTitle: "Create Template",
            action: { showingCreateTemplate = true }
        )
    }
    
    private var templateList: some View {
        List {
            ForEach(templates) { template in
                TemplateDetailRow(template: template) {
                    templateToEdit = template
                }
            }
            .onDelete(perform: deleteTemplates)
        }
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            context.delete(templates[index])
        }
        
        do {
            try context.save()
            HapticManager.shared.notification(.success)
        } catch {
            print("Error deleting template: \(error)")
        }
    }
}

struct TemplateDetailRow: View {
    let template: WorkoutTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(template.wrappedName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Label("\(template.exercisesArray.count) exercises", 
                          systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let createdAt = template.createdAt {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = template.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Exercise preview
                if !template.exercisesArray.isEmpty {
                    HStack {
                        ForEach(template.exercisesArray.prefix(3)) { templateExercise in
                            if let exercise = templateExercise.exercise {
                                Text(exercise.wrappedName)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(exercise.categoryEnum.color.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        
                        if template.exercisesArray.count > 3 {
                            Text("+\(template.exercisesArray.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}