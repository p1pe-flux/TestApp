//
//  SetRowView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
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
            Text("\(set.setNumber)")
                .frame(width: 30)
                .foregroundColor(set.completed ? .secondary : .primary)
            
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
            
            Button(action: toggleCompletion) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.completed ? Theme.Colors.success : .secondary)
                    .font(.title2)
            }
        }
        .onAppear {
            weight = set.weight > 0 ? set.formattedWeight : ""
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
        let weightValue = Double(weight) ?? 0
        let repsValue = Int16(reps) ?? 0
        viewModel.updateSet(set, weight: weightValue, reps: repsValue, completed: set.completed)
    }
    
    private func toggleCompletion() {
        viewModel.updateSet(set, weight: set.weight, reps: set.reps, completed: !set.completed)
        HapticManager.shared.impact(.medium)
    }
}