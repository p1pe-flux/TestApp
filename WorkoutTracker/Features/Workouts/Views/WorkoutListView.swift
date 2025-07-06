//
//  WorkoutListView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI
import CoreData

struct WorkoutListView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: WorkoutListViewModel
    @State private var showingCreateWorkout = false
    @State private var selectedWorkout: Workout?
    
    init() {
        let service = WorkoutService(context: PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: WorkoutListViewModel(workoutService: service))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "Loading workouts...")
                } else if viewModel.workouts.isEmpty {
                    emptyState
                } else {
                    workoutsList
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWorkout = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
            .sheet(item: $selectedWorkout) { workout in
                ActiveWorkoutView(workout: workout)
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "figure.strengthtraining.traditional",
            title: "No workouts yet",
            message: "Tap the + button to create your first workout",
            actionTitle: "Create Workout",
            action: { showingCreateWorkout = true }
        )
    }
    
    private var workoutsList: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.medium) {
                if !viewModel.todayWorkouts.isEmpty {
                    todaySection
                }
                
                allWorkoutsSection
            }
            .padding()
        }
    }
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Today")
                .font(.headline)
            
            ForEach(viewModel.todayWorkouts) { workout in
                WorkoutCard(workout: workout) {
                    selectedWorkout = workout
                }
            }
        }
    }
    
    private var allWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("All Workouts")
                .font(.headline)
            
            ForEach(viewModel.workouts) { workout in
                WorkoutCard(workout: workout) {
                    selectedWorkout = workout
                }
            }
        }
    }
}

// Agregar estas funciones a WorkoutListView.swift

extension WorkoutListView {
    // Quick actions para duplicación
    @ViewBuilder
    private func workoutRowWithActions(for workout: Workout) -> some View {
        WorkoutCard(workout: workout) {
            selectedWorkout = workout
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                duplicateWorkoutToToday(workout)
            } label: {
                Label("Today", systemImage: "calendar.badge.plus")
            }
            .tint(Theme.Colors.primary)
            
            Button {
                duplicateWorkoutToTomorrow(workout)
            } label: {
                Label("Tomorrow", systemImage: "calendar.badge.clock")
            }
            .tint(Theme.Colors.shoulders)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteWorkout(workout)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                workoutToDuplicate = workout
                showingDuplicateSheet = true
            } label: {
                Label("Custom", systemImage: "calendar")
            }
            .tint(Theme.Colors.info)
        }
        .contextMenu {
            Button(action: { duplicateWorkoutToToday(workout) }) {
                Label("Duplicate to Today", systemImage: "calendar.badge.plus")
            }
            
            Button(action: { duplicateWorkoutToTomorrow(workout) }) {
                Label("Duplicate to Tomorrow", systemImage: "calendar.badge.clock")
            }
            
            Button(action: { createTemplate(from: workout) }) {
                Label("Save as Template", systemImage: "square.and.arrow.down")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                Task {
                    await viewModel.deleteWorkout(workout)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func duplicateWorkoutToToday(_ workout: Workout) {
        duplicateWorkout(workout, to: Date(), name: "\(workout.wrappedName) - Today")
    }
    
    private func duplicateWorkoutToTomorrow(_ workout: Workout) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        duplicateWorkout(workout, to: tomorrow)
    }
    
    private func duplicateWorkout(_ workout: Workout, to date: Date, name: String? = nil) {
        let duplicationService = WorkoutDuplicationService(context: context)
        
        Task {
            do {
                _ = try duplicationService.duplicateWorkout(
                    workout,
                    toDate: date,
                    withName: name
                )
                HapticManager.shared.notification(.success)
                viewModel.loadWorkouts()
            } catch {
                print("Failed to duplicate workout: \(error)")
            }
        }
    }
    
    private func createTemplate(from workout: Workout) {
        let duplicationService = WorkoutDuplicationService(context: context)
        
        Task {
            do {
                _ = try duplicationService.createTemplate(
                    from: workout,
                    templateName: "\(workout.wrappedName) Template"
                )
                HapticManager.shared.notification(.success)
            } catch {
                print("Error creating template: \(error)")
            }
        }
    }
}
