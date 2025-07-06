import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorkoutTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    
    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample data
        SampleDataGenerator.generateSampleData(in: context)
        
        return controller
    }()
}

// MARK: - Sample Data Generator

struct SampleDataGenerator {
    static func generateSampleData(in context: NSManagedObjectContext) {
        // Sample exercises
        let exercises = [
            ("Bench Press", ExerciseCategory.chest.rawValue, [MuscleGroup.pectoralMajor.rawValue, MuscleGroup.tricepsBrachii.rawValue]),
            ("Squat", ExerciseCategory.legs.rawValue, [MuscleGroup.quadriceps.rawValue, MuscleGroup.glutes.rawValue]),
            ("Deadlift", ExerciseCategory.back.rawValue, [MuscleGroup.erectorSpinae.rawValue, MuscleGroup.hamstrings.rawValue]),
            ("Pull-up", ExerciseCategory.back.rawValue, [MuscleGroup.latissimusDorsi.rawValue, MuscleGroup.bicepsBrachii.rawValue])
        ]
        
        for (name, category, muscles) in exercises {
            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.name = name
            exercise.category = category
            exercise.muscleGroups = muscles as NSArray
            exercise.createdAt = Date()
            exercise.updatedAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to create sample data: \(error)")
        }
    }
}
