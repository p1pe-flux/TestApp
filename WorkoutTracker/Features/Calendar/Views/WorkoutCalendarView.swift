//
//  WorkoutCalendarView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct WorkoutCalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var selectedDate = Date()
    @State private var showingCreateWorkout = false
    
    init() {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                monthHeader
                weekdayHeader
                calendarGrid
                Spacer()
            }
            .navigationTitle("Calendar")
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: { viewModel.previousMonth() }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { viewModel.nextMonth() }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(viewModel.calendarDays) { day in
                CalendarDayView(
                    day: day,
                    workouts: viewModel.workoutsInMonth[Calendar.current.startOfDay(for: day.date)],
                    isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                ) {
                    selectedDate = day.date
                    if day.isInCurrentMonth {
                        showingCreateWorkout = true
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}