//
//  SetRowView.swift
//  WorkoutTracker
//
//  Vista para editar un set individual de ejercicio
//

import SwiftUI

struct SetRowView: View {
    let set: WorkoutSet
    @ObservedObject var viewModel: ActiveWorkoutViewModel
    @State private var weight: String = ""
    @State private var reps: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case weight, reps
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            // Número de set
            Text("\(set.setNumber)")
                .frame(width: 30)
                .foregroundColor(set.completed ? .secondary : .primary)
            
            // Campo de peso
            TextField("0", text: $weight)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: .weight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(focusedField == .weight ? Theme.Colors.primary : Color.clear, lineWidth: 1)
                )
            
            Text("×")
                .foregroundColor(.secondary)
            
            // Campo de repeticiones
            TextField("0", text: $reps)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: .reps)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(focusedField == .reps ? Theme.Colors.primary : Color.clear, lineWidth: 1)
                )
            
            // Botón de completado
            Button(action: toggleCompletion) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.completed ? Theme.Colors.success : .secondary)
                    .font(.title2)
            }
        }
        .onAppear {
            // Convert from storage unit to user's preferred unit for display
            let convertedWeight = UserPreferences.shared.convertFromStorageUnit(set.weight)
            weight = convertedWeight > 0 ? String(format: "%.1f", convertedWeight) : ""
            reps = set.reps > 0 ? "\(set.reps)" : ""
        }
        .onChange(of: weight) { _, newValue in
            updateSet()
        }
        .onChange(of: reps) { _, newValue in
            updateSet()
        }
    }
    
    private func updateSet() {
        // Weight input is in user's preferred unit, no need to convert here
        // The viewModel will handle conversion to storage unit
        let weightValue = Double(weight) ?? 0
        let repsValue = Int16(reps) ?? 0
        viewModel.updateSet(set, weight: weightValue, reps: repsValue, completed: set.completed)
    }
    
    private func toggleCompletion() {
        viewModel.updateSet(set, weight: set.weight, reps: set.reps, completed: !set.completed)
        HapticManager.shared.impact(.medium)
    }
}
