import Foundation
import CoreData

public struct ToDoTask: Codable {
    public var id: Int
    public var todo: String
    public var completed: Bool
    public var userId: Int
    
    public init(id: Int, todo: String, completed: Bool, userId: Int) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

public struct ToDoResponse: Codable {
    public var todos: [ToDoTask]
    public var total: Int
    public var skip: Int
    public var limit: Int
}

@objc(CoreDataTasks)
public class CoreDataTasks: NSManagedObject {

}

extension CoreDataTasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTasks> {
        return NSFetchRequest<CoreDataTasks>(entityName: "CoreDataTasks")
    }

    @NSManaged public var id: Int
    @NSManaged public var todo: String?
    @NSManaged public var completed: Bool
    @NSManaged public var userId: Int
    
    convenience init(id: Int, todo: String?, completed: Bool, userId: Int) async {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CoreDataTasks", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

extension CoreDataTasks : Identifiable {

}
