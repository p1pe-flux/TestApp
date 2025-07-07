//
//  ActiveWorkoutView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct ActiveWorkoutView: View {
    @StateObject private var viewModel: ActiveWorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEndWorkoutAlert = false
    
    init(workout: Workout) {
        let service = WorkoutService(context: workout.managedObjectContext ?? PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: ActiveWorkoutViewModel(workout: workout, workoutService: service))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            workoutHeader
            
            if viewModel.workoutExercises.isEmpty {
                emptyState
            } else {
                exercisesList
            }
            
            if viewModel.isRestTimerRunning {
                RestTimerView(
                    seconds: $viewModel.restTimerSeconds,
                    isRunning: $viewModel.isRestTimerRunning
                ) {
                    viewModel.stopRestTimer()
                }
                .transition(.move(edge: .bottom))
            }
        }
        .navigationTitle(viewModel.workout.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isTimerRunning)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(viewModel.isTimerRunning ? "End" : "Close") {
                    if viewModel.isTimerRunning {
                        showingEndWorkoutAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .alert("End Workout?", isPresented: $showingEndWorkoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Workout", role: .destructive) {
                viewModel.endWorkout()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to end this workout?")
        }
    }
    
    private var workoutHeader: some View {
        VStack(spacing: Theme.Spacing.medium) {
            TimerDisplay(time: viewModel.elapsedTime)
            
            HStack(spacing: Theme.Spacing.medium) {
                if viewModel.isTimerRunning {
                    Button("Pause") {
                        viewModel.pauseWorkout()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Resume") {
                        viewModel.resumeWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if viewModel.workout.totalSets > 0 {
                    HStack {
                        ProgressIndicator(progress: viewModel.workout.progress)
                            .frame(width: 32, height: 32)
                        
                        Text("\(viewModel.workout.completedSets)/\(viewModel.workout.totalSets)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "figure.strengthtraining.traditional",
            title: "No exercises added",
            message: "Add exercises to start your workout"
        )
    }
    
    private var exercisesList: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.medium) {
                ForEach(viewModel.workoutExercises) { workoutExercise in
                    ExerciseSection(
                        workoutExercise: workoutExercise,
                        viewModel: viewModel
                    )
                }
            }
            .padding()
        }
    }
}

struct ExerciseSection: View {
    let workoutExercise: WorkoutExercise
    @ObservedObject var viewModel: ActiveWorkoutViewModel
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(workoutExercise.exercise?.wrappedName ?? "Unknown Exercise")
                        .font(.headline)
                    
                    Spacer()
                    
                    if workoutExercise.completedSetsCount > 0 {
                        Text("\(workoutExercise.completedSetsCount)/\(workoutExercise.setsArray.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.primary.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: Theme.Spacing.small) {
                    ForEach(workoutExercise.setsArray) { set in
                        EnhancedSetRow(set: set, viewModel: viewModel)
                    }
                    
                    Button(action: { viewModel.addSet(to: workoutExercise) }) {
                        Label("Add Set", systemImage: "plus.circle")
                            .font(.subheadline)
                    }
                    .padding(.top, Theme.Spacing.xSmall)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
}
