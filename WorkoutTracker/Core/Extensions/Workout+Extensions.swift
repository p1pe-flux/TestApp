import Foundation

extension Workout {
    var wrappedName: String {
        name ?? "Unnamed Workout"
    }
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var workoutExercisesArray: [WorkoutExercise] {
        let set = workoutExercises as? Set<WorkoutExercise> ?? []
        return set.sorted { $0.order < $1.order }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date ?? Date())
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var totalSets: Int {
        workoutExercisesArray.reduce(0) { $0 + $1.setsArray.count }
    }
    
    var completedSets: Int {
        workoutExercisesArray.reduce(0) { $0 + $1.setsArray.filter { $0.completed }.count }
    }
    
    var progress: Double {
        guard totalSets > 0 else { return 0 }
        return Double(completedSets) / Double(totalSets)
    }
    
    var isCompleted: Bool {
        totalSets > 0 && completedSets == totalSets
    }
    
    var totalVolume: Double {
        workoutExercisesArray.reduce(0) { $0 + $1.totalVolume }
    }
}
