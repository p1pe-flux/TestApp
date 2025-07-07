//
//  WorkoutDetailCard.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct WorkoutDetailCard: View {
    let workout: Workout
    @State private var isExpanded = false
    @State private var showingEditView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            // Header
            workoutHeader
            
            // Stats summary
            statsSummary
            
            // Exercises section
            if isExpanded {
                exercisesSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Notes section
            if isExpanded && !workout.wrappedNotes.isEmpty {
                notesSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cardStyle()
        .sheet(isPresented: $showingEditView) {
            // Edit workout view would go here
        }
    }
    
    private var workoutHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.wrappedName)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(workout.date?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: Theme.Spacing.small) {
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.success)
                } else if workout.totalSets > 0 {
                    ProgressIndicator(progress: workout.progress)
                        .frame(width: 30, height: 30)
                }
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statsSummary: some View {
        HStack {
            StatBadge(
                value: "\(workout.workoutExercisesArray.count)",
                label: "Exercises",
                color: Theme.Colors.primary
            )
            
            Spacer()
            
            StatBadge(
                value: "\(workout.totalSets)",
                label: "Sets",
                color: Theme.Colors.shoulders
            )
            
            Spacer()
            
            StatBadge(
                value: formatVolume(workout.totalVolume),
                label: "Volume",
                color: Theme.Colors.success
            )
            
            Spacer()
            
            if workout.duration > 0 {
                StatBadge(
                    value: workout.formattedDuration,
                    label: "Duration",
                    color: Theme.Colors.info
                )
            }
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Exercises")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(workout.workoutExercisesArray) { workoutExercise in
                ExerciseSummaryRow(workoutExercise: workoutExercise)
                
                if workoutExercise != workout.workoutExercisesArray.last {
                    Divider()
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text("Notes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(workout.wrappedNotes)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
            let converted = UserPreferences.shared.weightUnit.convert(volume, to: UserPreferences.shared.weightUnit)
            if converted >= 1000 {
                return String(format: "%.1fk", converted / 1000)
            }
            return String(format: "%.0f", converted)
        }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ExerciseSummaryRow: View {
    let workoutExercise: WorkoutExercise
    @State private var showingDetail = false
    
    private var bestSet: WorkoutSet? {
        workoutExercise.setsArray
            .filter { $0.completed }
            .max { ($0.weight * Double($0.reps)) < ($1.weight * Double($1.reps)) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            HStack {
                Text(workoutExercise.exercise?.wrappedName ?? "Unknown Exercise")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if showingDetail {
                    Button(action: { showingDetail.toggle() }) {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text("\(workoutExercise.completedSetsCount)/\(workoutExercise.setsArray.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let bestSet = bestSet {
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Best: \(UserPreferences.shared.formatWeight(bestSet.weight)) × \(bestSet.reps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !showingDetail {
                    Button(action: { showingDetail.toggle() }) {
                        Text("Details")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }
            
            if showingDetail {
                VStack(spacing: Theme.Spacing.xSmall) {
                    ForEach(workoutExercise.setsArray) { set in
                        SetSummaryRow(set: set)
                    }
                }
                .padding(.top, Theme.Spacing.xSmall)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct SetSummaryRow: View {
    let set: WorkoutSet
    
    var body: some View {
        HStack {
            Text("Set \(set.setNumber)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            HStack(spacing: 4) {
                Text(UserPreferences.shared.formatWeight(set.weight))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("×")
                    .foregroundColor(.secondary)
                
                Text("\(set.reps)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if set.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.success)
            } else {
                Image(systemName: "circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
