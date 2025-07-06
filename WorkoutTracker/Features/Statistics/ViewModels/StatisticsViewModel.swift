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
                isLoading = false
            } catch {
                print("Error loading statistics: \(error)")
                isLoading = false
            }
        }
    }
}