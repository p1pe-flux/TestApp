//
//  Calendar+Extensions.swift
//  WorkoutTracker
//
//  Extensiones útiles para trabajar con fechas en el calendario
//

import Foundation

extension Calendar {
    /// Verifica si una fecha es mañana
    func isDateInTomorrow(_ date: Date) -> Bool {
        guard let tomorrow = self.date(byAdding: .day, value: 1, to: Date()) else { return false }
        return self.isDate(date, inSameDayAs: tomorrow)
    }
    
    /// Obtiene el inicio de la semana para una fecha dada
    func startOfWeek(for date: Date) -> Date? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)
    }
    
    /// Obtiene el final de la semana para una fecha dada
    func endOfWeek(for date: Date) -> Date? {
        guard let startOfWeek = startOfWeek(for: date) else { return nil }
        return self.date(byAdding: .day, value: 6, to: startOfWeek)
    }
    
    /// Verifica si dos fechas están en la misma semana
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        return self.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }
    
    /// Obtiene todos los días de un mes específico
    func daysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = dateInterval(of: .month, for: date),
              let monthFirstWeek = dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            days.append(currentDate)
            guard let nextDay = self.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return days
    }
    
    /// Obtiene el nombre del mes y año para una fecha
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Obtiene el número de semanas en un mes
    func numberOfWeeksInMonth(for date: Date) -> Int {
        guard let monthInterval = dateInterval(of: .month, for: date) else { return 0 }
        return numberOfWeeks(from: monthInterval.start, to: monthInterval.end)
    }
    
    /// Calcula el número de semanas entre dos fechas
    func numberOfWeeks(from startDate: Date, to endDate: Date) -> Int {
        let weeks = dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 0
        return weeks
    }
}

extension Date {
    /// Verifica si la fecha es en el pasado
    var isPast: Bool {
        return self < Date()
    }
    
    /// Verifica si la fecha es en el futuro
    var isFuture: Bool {
        return self > Date()
    }
    
    /// Obtiene el inicio del día para esta fecha
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Obtiene el final del día para esta fecha
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Obtiene una representación amigable de la fecha relativa a hoy
    var relativeString: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
    
    /// Formatea la fecha para mostrar en el calendario
    func calendarDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    /// Obtiene el nombre del día de la semana
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    /// Obtiene el nombre del mes
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
}
