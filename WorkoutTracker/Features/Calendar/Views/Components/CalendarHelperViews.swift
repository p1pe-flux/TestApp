//
//  CalendarHelperViews.swift
//  WorkoutTracker
//
//  Vistas auxiliares específicas para el calendario
//

import SwiftUI

// MARK: - Calendar Header Components

struct CalendarMonthNavigationHeader: View {
    let currentMonth: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.title2)
                .fontWeight(.semibold)
                .animation(.none, value: currentMonth)
            
            Spacer()
            
            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal)
    }
}

struct CalendarWeekdayHeader: View {
    var body: some View {
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
}

// MARK: - Calendar Grid Components

struct CalendarGrid: View {
    let calendarDays: [CalendarDay]
    let workoutsInMonth: [Date: [Workout]]
    let selectedDate: Date?
    let onDateSelected: (CalendarDay) -> Void
    let showSelection: Bool
    
    init(
        calendarDays: [CalendarDay],
        workoutsInMonth: [Date: [Workout]],
        selectedDate: Date? = nil,
        showSelection: Bool = false,
        onDateSelected: @escaping (CalendarDay) -> Void
    ) {
        self.calendarDays = calendarDays
        self.workoutsInMonth = workoutsInMonth
        self.selectedDate = selectedDate
        self.showSelection = showSelection
        self.onDateSelected = onDateSelected
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 8) {
            ForEach(calendarDays) { day in
                if showSelection {
                    CalendarDaySelectionView(
                        day: day,
                        workouts: workoutsInMonth[Calendar.current.startOfDay(for: day.date)],
                        isSelected: selectedDate != nil && Calendar.current.isDate(day.date, inSameDayAs: selectedDate!),
                        isToday: Calendar.current.isDateInToday(day.date)
                    ) {
                        if day.isInCurrentMonth {
                            onDateSelected(day)
                        }
                    }
                } else {
                    CalendarDayView(
                        day: day,
                        workouts: workoutsInMonth[Calendar.current.startOfDay(for: day.date)],
                        isSelected: selectedDate != nil && Calendar.current.isDate(day.date, inSameDayAs: selectedDate!)
                    ) {
                        if day.isInCurrentMonth {
                            onDateSelected(day)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Workout Day Information Components

struct WorkoutDayInfoSection: View {
    let selectedDate: Date
    let workouts: [Workout]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Divider()
            
            // Información de la fecha seleccionada
            selectedDateCard
            
            // Lista de workouts para esta fecha
            workoutsListSection
        }
    }
    
    private var selectedDateCard: some View {
        EmptyView()
    }
    
    private var workoutsListSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Text("Workouts for this day")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !workouts.isEmpty {
                    Text("\(workouts.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.primary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if workouts.isEmpty {
                EmptyWorkoutDayView()
            } else {
                WorkoutDayListView(workouts: workouts)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Calendar State Views

struct CalendarLoadingView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading calendar...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct CalendarErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Calendar Error")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Quick Action Buttons

struct CalendarQuickActionButtons: View {
    let onCreateToday: () -> Void
    let onCreateTomorrow: () -> Void
    let onViewTemplates: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            QuickActionButton(
                title: "Today",
                icon: "star.fill",
                color: Theme.Colors.primary
            ) {
                onCreateToday()
            }
            
            QuickActionButton(
                title: "Tomorrow",
                icon: "sunrise.fill",
                color: Theme.Colors.shoulders
            ) {
                onCreateTomorrow()
            }
            
            QuickActionButton(
                title: "Templates",
                icon: "doc.text",
                color: Theme.Colors.info
            ) {
                onViewTemplates()
            }
        }
        .padding()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

// MARK: - Calendar Statistics Card

struct CalendarStatsCard: View {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let weekStreak: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            StatItem(
                value: "\(totalWorkouts)",
                label: "This Month",
                icon: "calendar"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: "\(completedWorkouts)",
                label: "Completed",
                icon: "checkmark.circle.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: "\(weekStreak)",
                label: "Week Streak",
                icon: "flame.fill"
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.primary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
