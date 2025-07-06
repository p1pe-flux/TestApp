//
//  CalendarDayView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDay
    let workouts: [Workout]?
    let isSelected: Bool
    let action: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(day.date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day.dayNumber)")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if let workouts = workouts, !workouts.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(0..<min(workouts.count, 3), id: \.self) { _ in
                            Circle()
                                .fill(Theme.Colors.primary)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!day.isInCurrentMonth)
    }
    
    private var textColor: Color {
        if !day.isInCurrentMonth {
            return Color.secondary.opacity(0.3)
        } else if isSelected || isToday {
            return isToday ? Theme.Colors.primary : .primary
        } else {
            return .primary
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.Colors.primary.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.Colors.primary, lineWidth: 2)
                )
        } else if isToday {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.Colors.primary, lineWidth: 1)
        }
    }
}