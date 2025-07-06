import Foundation
import CoreData

protocol ExerciseServiceProtocol {
    func createExercise(name: String, category: String, muscleGroups: [String], notes: String?) throws -> Exercise
    func fetchAllExercises() throws -> [Exercise]
    func updateExercise(_ exercise: Exercise) throws
    func deleteExercise(_ exercise: Exercise) throws
    func searchExercises(query: String) throws -> [Exercise]
}

class ExerciseService: ExerciseServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createExercise(name: String, category: String, muscleGroups: [String] = [], notes: String? = nil) throws -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.category = category
        exercise.muscleGroups = muscleGroups as NSArray
        exercise.notes = notes
        exercise.createdAt = Date()
        exercise.updatedAt = Date()
        
        try context.save()
        return exercise
    }
    
    func fetchAllExercises() throws -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        return try context.fetch(request)
    }
    
    func updateExercise(_ exercise: Exercise) throws {
        exercise.updatedAt = Date()
        try context.save()
    }
    
    func deleteExercise(_ exercise: Exercise) throws {
        context.delete(exercise)
        try context.save()
    }
    
    func searchExercises(query: String) throws -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR category CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", query, query, query)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        return try context.fetch(request)
    }
}
