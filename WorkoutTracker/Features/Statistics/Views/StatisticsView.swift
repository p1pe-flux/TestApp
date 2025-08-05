//
//  StatisticsView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @State private var selectedExercise: Exercise?
    
    init() {
        let service = StatisticsService(context: PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(statisticsService: service))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    timeRangeSelector
                    
                    if viewModel.isLoading {
                        LoadingView(message: "Loading statistics...")
                            .frame(height: 200)
                    } else if let stats = viewModel.workoutStats {
                        overviewSection(stats: stats)
                        
                        if !viewModel.frequentExercises.isEmpty {
                            frequentExercisesSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .sheet(item: $selectedExercise) { exercise in
                ExerciseProgressView(exercise: exercise)
            }
        }
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(StatisticsViewModel.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: viewModel.selectedTimeRange) { _, _ in
            viewModel.loadStatistics()
        }
    }
    
    private func overviewSection(stats: WorkoutStatistics) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack(spacing: Theme.Spacing.medium) {
                StatCard(
                    title: "Workouts",
                    value: "\(stats.totalWorkouts)",
                    icon: "dumbbell"
                )
                
                StatCard(
                    title: "Total Volume",
                    value: UserPreferences.shared.formatWeight(UserPreferences.shared.convertFromStorageUnit(stats.totalVolume)),
                    icon: "scalemass"
                )
            }
            
            HStack(spacing: Theme.Spacing.medium) {
                StatCard(
                    title: "Total Sets",
                    value: "\(stats.totalSets)",
                    icon: "list.number"
                )
                
                StatCard(
                    title: "Avg Duration",
                    value: formatDuration(stats.averageDuration),
                    icon: "clock"
                )
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
    
    private var frequentExercisesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Ejercicios Frecuentes")
                .font(.headline)
            
            ForEach(viewModel.frequentExercises) { exerciseData in
                FrequentExerciseRow(exerciseData: exerciseData) {
                    showExerciseProgress(for: exerciseData.exercise)
                }
            }
        }
        .padding(.top, Theme.Spacing.large)
    }
    
    private func showExerciseProgress(for exercise: Exercise) {
        selectedExercise = exercise
    }
}
