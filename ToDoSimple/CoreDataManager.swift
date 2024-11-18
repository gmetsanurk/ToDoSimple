import CoreData

enum CoreDataError: Error {
    case entityInsertionFailed
    case contextSaveFailed(Error)
    case fetchFailed(Error)
}

class CoreDataManager {
    public static let shared = CoreDataManager()

    private init() { }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataTasks")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    public func logCoreDataDBPath() {
        if let url = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print("DataBase URL - \(url)")
        }
    }

    private func fetchTasks() -> [CoreDataTasks] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataTasks")
        do {
            return (try? context.fetch(fetchRequest) as? [CoreDataTasks]) ?? []
        }
    }
    
    func deleteAllTasks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataTasks")
        do {
            let tasks = try? context.fetch(fetchRequest) as? [CoreDataTasks]
            tasks?.forEach{ context.delete($0)}
        }
    }
    
    private func coreDataIsEmpty() async -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoreDataTasks")
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Check Error")
            return true
        }
    }
}

extension CoreDataManager {
    func save(for todos: [ToDoTask]) async throws {
        let backgroundContext = self.context

        try await backgroundContext.perform {
            for task in todos {
                guard let tasksEntity = NSEntityDescription.insertNewObject(
                    forEntityName: "CoreDataTasks",
                    into: backgroundContext
                ) as? CoreDataTasks else {
                    throw CoreDataError.entityInsertionFailed
                }

                tasksEntity.id = task.id
                tasksEntity.todo = task.todo
                tasksEntity.completed = task.completed
                tasksEntity.userId = task.userId
            }

            do {
                try backgroundContext.save()
            } catch {
                backgroundContext.rollback()
                throw CoreDataError.contextSaveFailed(error)
            }
        }
    }
    
    func fetchTodos() async throws -> [ToDoTask] {
        let backgroundContext = self.context

        return try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<CoreDataTasks> = CoreDataTasks.fetchRequest()
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                return results.map { entity in
                    ToDoTask(
                        id: entity.id,
                        todo: entity.todo ?? "",
                        completed: entity.completed,
                        userId: entity.userId
                    )
                }
            } catch {
                throw CoreDataError.fetchFailed(error)
            }
        }
    }
}
