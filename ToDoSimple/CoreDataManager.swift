import CoreData

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
