//
//  WorkoutListView.swift
//  WorkoutTracker
//
//  Vista principal para mostrar la lista de entrenamientos agrupados por semana
//

import SwiftUI
import CoreData

struct WorkoutListView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: WorkoutListViewModel
    @State private var showingCreateWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var workoutToDuplicate: Workout?
    @State private var showingDuplicateSheet = false
    @State private var expandedWeeks: Set<String> = []
    
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
            .sheet(item: $workoutToDuplicate) { workout in
                DuplicateWorkoutView(workout: workout)
            }
        }
        .onAppear {
            // Expandir la semana actual por defecto
            if let currentWeekKey = weekKey(for: Date()) {
                expandedWeeks.insert(currentWeekKey)
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
                // Sección de hoy si hay workouts
                if !viewModel.todayWorkouts.isEmpty {
                    todaySection
                }
                
                // Workouts agrupados por semana
                ForEach(groupedWorkoutsByWeek.sorted(by: { $0.key > $1.key }), id: \.key) { weekKey, workouts in
                    weekSection(weekKey: weekKey, workouts: workouts)
                }
            }
            .padding()
        }
    }
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("Today's Workouts")
                    .font(.headline)
            }
            
            ForEach(viewModel.todayWorkouts) { workout in
                workoutRowWithActions(for: workout)
            }
        }
        .padding()
        .background(Theme.Colors.primary.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private func weekSection(weekKey: String, workouts: [Workout]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // Header de la semana
            Button(action: { toggleWeek(weekKey) }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weekTitleFromKey(weekKey))
                            .font(.headline)
                        
                        Text("\(workouts.count) workout\(workouts.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: expandedWeeks.contains(weekKey) ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Workouts de la semana (si está expandida)
            if expandedWeeks.contains(weekKey) {
                VStack(spacing: Theme.Spacing.small) {
                    ForEach(workouts.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) })) { workout in
                        workoutRowWithActions(for: workout)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    // MARK: - Helper Functions
    
    private var groupedWorkoutsByWeek: [String: [Workout]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.workouts.filter { workout in
            // Excluir los workouts de hoy que ya se muestran arriba
            if let date = workout.date,
               calendar.isDateInToday(date) {
                return false
            }
            return true
        }) { workout -> String in
            guard let date = workout.date else { return "" }
            return weekKey(for: date) ?? ""
        }
        
        return grouped.filter { !$0.key.isEmpty }
    }
    
    private func weekKey(for date: Date) -> String? {
        let calendar = Calendar.current
        guard let weekOfYear = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date).weekOfYear,
              let year = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date).yearForWeekOfYear else {
            return nil
        }
        return "\(year)-W\(String(format: "%02d", weekOfYear))"
    }
    
    private func weekTitleFromKey(_ key: String) -> String {
        // Formato: "2025-W02"
        let components = key.split(separator: "-")
        guard components.count == 2,
              let year = Int(components[0]),
              let weekNumber = Int(components[1].dropFirst()) else {
            return "Unknown Week"
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.yearForWeekOfYear = year
        dateComponents.weekOfYear = weekNumber
        dateComponents.weekday = 2 // Lunes
        
        guard let startOfWeek = calendar.date(from: dateComponents) else {
            return "Week \(weekNumber), \(year)"
        }
        
        // Si es la semana actual
        if calendar.isDate(startOfWeek, equalTo: Date(), toGranularity: .weekOfYear) {
            return "This Week"
        }
        
        // Si es la semana pasada
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()),
           calendar.isDate(startOfWeek, equalTo: lastWeek, toGranularity: .weekOfYear) {
            return "Last Week"
        }
        
        // Para otras semanas
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return "Week \(weekNumber)"
        }
        
        // Si cruza meses o años
        if calendar.component(.month, from: startOfWeek) != calendar.component(.month, from: endOfWeek) ||
           calendar.component(.year, from: startOfWeek) != calendar.component(.year, from: endOfWeek) {
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startOfWeek)
            formatter.dateFormat = calendar.component(.year, from: startOfWeek) != calendar.component(.year, from: endOfWeek) ? "MMM d, yyyy" : "MMM d"
            let end = formatter.string(from: endOfWeek)
            return "\(start) - \(end)"
        } else {
            return "\(formatter.string(from: startOfWeek)) - \(calendar.component(.day, from: endOfWeek))"
        }
    }
    
    private func toggleWeek(_ weekKey: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedWeeks.contains(weekKey) {
                expandedWeeks.remove(weekKey)
            } else {
                expandedWeeks.insert(weekKey)
            }
        }
    }
    
    // MARK: - Workout Row with Swipe Actions
    
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
    
    // MARK: - Duplication Functions
    
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
