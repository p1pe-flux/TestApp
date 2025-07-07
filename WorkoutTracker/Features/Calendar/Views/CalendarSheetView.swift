//
//  CalendarSheetView.swift
//  WorkoutTracker
//
//  Vista modular del calendario para seleccionar fechas y crear workouts
//

import SwiftUI
import CoreData

struct CalendarSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CalendarViewModel
    @State private var selectedDate: Date?
    @State private var isCreating = false
    let onDateSelected: (Date) -> Void
    
    init(onDateSelected: @escaping (Date) -> Void) {
        self.onDateSelected = onDateSelected
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                calendarSection
                
                if let selectedDate = selectedDate {
                    selectedDateSection(selectedDate)
                }
                
                Spacer()
            }
            .navigationTitle("Schedule Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let date = selectedDate, !isCreating {
                            isCreating = true
                            onDateSelected(date)
                        }
                    }) {
                        if isCreating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(selectedDate == nil || isCreating)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: 0) {
            monthHeader
            weekdayHeader
            calendarGrid
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: { viewModel.previousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Spacer()
            
            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { viewModel.nextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 8) {
            ForEach(viewModel.calendarDays) { day in
                CalendarDaySelectionView(
                    day: day,
                    workouts: viewModel.workoutsInMonth[Calendar.current.startOfDay(for: day.date)],
                    isSelected: selectedDate != nil && Calendar.current.isDate(day.date, inSameDayAs: selectedDate!),
                    isToday: Calendar.current.isDateInToday(day.date)
                ) {
                    if day.isInCurrentMonth {
                        selectedDate = day.date
                        HapticManager.shared.impact(.light)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func selectedDateSection(_ date: Date) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            Divider()
            
            // Información de la fecha seleccionada
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(date.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.Colors.success)
                    .font(.title2)
            }
            .padding()
            .background(Theme.Colors.success.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.medium)
            .padding(.horizontal)
            
            // Workouts para esta fecha
            workoutsForSelectedDate(date)
        }
    }
    
    private func workoutsForSelectedDate(_ date: Date) -> some View {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let workoutsForDay = viewModel.workoutsInMonth[startOfDay] ?? []
        
        return VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Text("Workouts for this day")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(workoutsForDay.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if workoutsForDay.isEmpty {
                EmptyWorkoutDayView()
            } else {
                WorkoutDayListView(workouts: workoutsForDay)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Calendar Day Selection View

struct CalendarDaySelectionView: View {
    let day: CalendarDay
    let workouts: [Workout]?
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day.dayNumber)")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                workoutIndicators
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!day.isInCurrentMonth)
    }
    
    @ViewBuilder
    private var workoutIndicators: some View {
        if let workouts = workouts, !workouts.isEmpty {
            HStack(spacing: 2) {
                ForEach(0..<min(workouts.count, 3), id: \.self) { _ in
                    Circle()
                        .fill(isSelected ? .white : Theme.Colors.primary)
                        .frame(width: 4, height: 4)
                }
                
                if workouts.count > 3 {
                    Text("+")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                }
            }
        } else {
            // Placeholder para mantener la altura consistente
            Spacer()
                .frame(height: 8)
        }
    }
    
    private var textColor: Color {
        if !day.isInCurrentMonth {
            return Color.secondary.opacity(0.3)
        } else if isSelected {
            return .white
        } else if isToday {
            return Theme.Colors.primary
        } else {
            return .primary
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.Colors.primary)
        } else if isToday {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.Colors.primary, lineWidth: 2)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
        }
    }
}

// MARK: - Supporting Views

struct EmptyWorkoutDayView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No workouts scheduled")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Perfect day to add a new workout!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct WorkoutDayListView: View {
    let workouts: [Workout]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xSmall) {
            ForEach(workouts.sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })) { workout in
                WorkoutDayRowView(workout: workout)
                
                if workout != workouts.last {
                    Divider()
                        .padding(.leading, 40)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
}

struct WorkoutDayRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            // Icono de estado
            Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : workout.totalSets > 0 ? "clock.circle" : "circle")
                .foregroundColor(workout.isCompleted ? Theme.Colors.success : workout.totalSets > 0 ? Theme.Colors.warning : .secondary)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.wrappedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack {
                    if let date = workout.date {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if workout.workoutExercisesArray.count > 0 {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(workout.workoutExercisesArray.count) exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if workout.totalSets > 0 {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(workout.completedSets)/\(workout.totalSets) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if workout.isCompleted {
                Text("DONE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.success)
                    .cornerRadius(4)
            } else if workout.totalSets > 0 {
                Text("IN PROGRESS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.warning)
                    .cornerRadius(4)
            }
        }
    }
}
