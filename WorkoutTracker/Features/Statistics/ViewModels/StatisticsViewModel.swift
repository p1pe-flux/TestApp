//
//  StatisticsViewModel.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var workoutStats: WorkoutStatistics?
    @Published var recentExerciseStats: [ExerciseStatistics] = []
    @Published var frequentExercises: [FrequentExerciseData] = []
    @Published var isLoading = false
    @Published var selectedTimeRange = TimeRange.month
    
    private let statisticsService: StatisticsService
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case all = "All Time"
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .week:
                let start = calendar.date(byAdding: .day, value: -7, to: now)!
                return (start, now)
            case .month:
                let start = calendar.date(byAdding: .month, value: -1, to: now)!
                return (start, now)
            case .threeMonths:
                let start = calendar.date(byAdding: .month, value: -3, to: now)!
                return (start, now)
            case .year:
                let start = calendar.date(byAdding: .year, value: -1, to: now)!
                return (start, now)
            case .all:
                let start = calendar.date(byAdding: .year, value: -10, to: now)!
                return (start, now)
            }
        }
    }
    
    init(statisticsService: StatisticsService) {
        self.statisticsService = statisticsService
        loadStatistics()
    }
    
    func loadStatistics() {
        isLoading = true
        
        Task {
            do {
                let (start, end) = selectedTimeRange.dateRange
                workoutStats = try statisticsService.getWorkoutStats(from: start, to: end)
                frequentExercises = try await loadFrequentExercises(from: start, to: end)
                isLoading = false
            } catch {
                print("Error loading statistics: \(error)")
                isLoading = false
            }
        }
    }
    
    private func loadFrequentExercises(from startDate: Date, to endDate: Date) async throws -> [FrequentExerciseData] {
        let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(
            format: "workout.date >= %@ AND workout.date <= %@",
            startDate as CVarArg,
            endDate as CVarArg
        )
        
        let context = statisticsService.context
        let workoutExercises = try context.fetch(request)
        
        // Agrupar por ejercicio
        let exerciseGroups = Dictionary(grouping: workoutExercises) { $0.exercise }
        
        return exerciseGroups.compactMap { (exercise, workoutExercises) in
            guard let exercise = exercise else { return nil }
            
            let sortedByDate = workoutExercises
                .compactMap { $0.workout?.date }
                .sorted(by: >)
            
            let lastPerformed = sortedByDate.first
            
            // Calcular tendencia comparando con período anterior
            let trend = calculateTrend(for: exercise, currentCount: workoutExercises.count)
            
            return FrequentExerciseData(
                exercise: exercise,
                timesPerformed: workoutExercises.count,
                lastPerformed: lastPerformed,
                trend: trend
            )
        }
        .sorted { $0.timesPerformed > $1.timesPerformed }
        .prefix(5) // Mostrar solo los 5 más frecuentes
        .map { $0 }
    }
    
    private func calculateTrend(for exercise: Exercise, currentCount: Int) -> ExerciseTrend? {
        // Aquí podrías implementar lógica para comparar con el período anterior
        // Por ahora retornamos nil
        return nil
    }
}
