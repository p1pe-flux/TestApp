//
//  CalendarViewModel.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var currentMonth = Date()
    @Published var calendarDays: [CalendarDay] = []
    @Published var workoutsInMonth: [Date: [Workout]] = [:]
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadMonth(for: currentMonth)
    }
    
    func loadMonth(for date: Date) {
        generateCalendarDays(for: date)
        loadWorkouts(for: date)
    }
    
    func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        loadMonth(for: currentMonth)
    }
    
    func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        loadMonth(for: currentMonth)
    }
    
    private func generateCalendarDays(for date: Date) {
        var days: [CalendarDay] = []
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        // Add previous month's trailing days
        if firstWeekday > 0 {
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth) else { return }
            let previousMonthDays = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 30
            
            for day in (previousMonthDays - firstWeekday + 1)...previousMonthDays {
                if let date = calendar.date(byAdding: .day, value: day - previousMonthDays - 1, to: firstOfMonth) {
                    days.append(CalendarDay(date: date, dayNumber: day, isInCurrentMonth: false))
                }
            }
        }
        
        // Add current month's days
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(CalendarDay(date: date, dayNumber: day, isInCurrentMonth: true))
            }
        }
        
        // Add next month's leading days
        let remainingDays = 42 - days.count
        for day in 1...remainingDays {
            if let date = calendar.date(byAdding: .month, value: 1, to: firstOfMonth),
               let nextMonthDate = calendar.date(byAdding: .day, value: day - 1, to: date) {
                days.append(CalendarDay(date: nextMonthDate, dayNumber: day, isInCurrentMonth: false))
            }
        }
        
        calendarDays = days
    }
    
    private func loadWorkouts(for date: Date) {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return }
        
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                       monthInterval.start as CVarArg,
                                       monthInterval.end as CVarArg)
        
        do {
            let workouts = try context.fetch(request)
            
            var grouped: [Date: [Workout]] = [:]
            for workout in workouts {
                guard let workoutDate = workout.date else { continue }
                let startOfDay = calendar.startOfDay(for: workoutDate)
                grouped[startOfDay, default: []].append(workout)
            }
            
            workoutsInMonth = grouped
        } catch {
            print("Error loading workouts: \(error)")
        }
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isInCurrentMonth: Bool
}