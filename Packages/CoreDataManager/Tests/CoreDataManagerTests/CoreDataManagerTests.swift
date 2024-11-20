import XCTest
import CoreData
@testable import CoreDataManager

class CoreDataTestBase: XCTestCase {
    private let modelName = "ToDoSimple"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCoreDataSetup() throws {
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
            XCTFail("Failed to locate CoreData model")
            return
        }
        
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        XCTAssertNotNil(managedObjectModel, "Failed to load CoreData model")
        
        let storeURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let container = NSPersistentContainer(name: "TestModel", managedObjectModel: managedObjectModel!)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (description, error) in
            XCTAssertNil(error, "Failed to load persistent stores: \(error!)")
        }
    }
    
    func testSaveTask() async throws {
        let testContainer = try createTestContainer()
        let coreDataManager = CoreDataManager(container: testContainer)
        
        let testTask = ToDoTask(id: 1, todo: "Test Task", completed: false, userId: 100)
        
        try await coreDataManager.save(forOneTask: testTask)
        
        let fetchedTasks = try await coreDataManager.getTodos()
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.id, testTask.id)
        XCTAssertEqual(fetchedTasks.first?.todo, testTask.todo)
        XCTAssertEqual(fetchedTasks.first?.completed, testTask.completed)
        XCTAssertEqual(fetchedTasks.first?.userId, testTask.userId)
    }
    
    func testDeleteAllTasks() async throws {
        let testContainer = try createTestContainer()
        let coreDataManager = CoreDataManager(container: testContainer)
        
        let tasks = [
            ToDoTask(id: 1, todo: "Task 1", completed: false, userId: 100),
            ToDoTask(id: 2, todo: "Task 2", completed: true, userId: 101)
        ]
        try await coreDataManager.save(forMultipleTasks: tasks)
        
        coreDataManager.deleteAllTasks()
        
        let fetchedTasks = try await coreDataManager.getTodos()
        XCTAssertEqual(fetchedTasks.count, 0)
    }
    
    func testGetNextID() async throws {
        let coreDataManager = CoreDataManager.shared
        
        let testTask = ToDoTask(id: 1, todo: "Test Task", completed: false, userId: 100)
        try await coreDataManager.save(forOneTask: testTask)
        
        let nextID = try await coreDataManager.getNextID()
        XCTAssertEqual(nextID, 2)
    }
}

extension CoreDataTestBase {
    
    func createTestContainer() throws -> NSPersistentContainer {
        
        let storeURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to locate CoreData model"])
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load CoreData model"])
        }
        
        let container = NSPersistentContainer(name: "TestModel", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container
    }
    
}
