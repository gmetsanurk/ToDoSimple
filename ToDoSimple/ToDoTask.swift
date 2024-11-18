import Foundation
import CoreData

struct ToDoTask: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
}

struct ToDoResponse: Codable {
    var todos: [ToDoTask]
    var total: Int
    var skip: Int
    var limit: Int
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
    
    convenience init(code: String, fullName: String) async {
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
