import Foundation
import CoreData

protocol WorkoutServiceProtocol {
    func createWorkout(name: String, date: Date, notes: String?) throws -> Workout
    func fetchAllWorkouts() throws -> [Workout]
    func fetchTodayWorkouts() throws -> [Workout]
    func updateWorkout(_ workout: Workout) throws
    func deleteWorkout(_ workout: Workout) throws
    func startWorkout(_ workout: Workout) throws
    func endWorkout(_ workout: Workout, duration: TimeInterval) throws
}

class WorkoutService: WorkoutServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createWorkout(name: String, date: Date = Date(), notes: String? = nil) throws -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.name = name
        workout.date = date
        workout.notes = notes
        workout.createdAt = Date()
        workout.updatedAt = Date()
        
        try context.save()
        return workout
    }
    
    func fetchAllWorkouts() throws -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        return try context.fetch(request)
    }
    
    func fetchTodayWorkouts() throws -> [Workout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: true)]
        
        return try context.fetch(request)
    }
    
    func updateWorkout(_ workout: Workout) throws {
        workout.updatedAt = Date()
        try context.save()
    }
    
    func deleteWorkout(_ workout: Workout) throws {
        context.delete(workout)
        try context.save()
    }
    
    func startWorkout(_ workout: Workout) throws {
        workout.date = Date()
        workout.updatedAt = Date()
        try context.save()
    }
    
    func endWorkout(_ workout: Workout, duration: TimeInterval) throws {
        workout.duration = Int32(duration)
        workout.updatedAt = Date()
        try context.save()
    }
}
