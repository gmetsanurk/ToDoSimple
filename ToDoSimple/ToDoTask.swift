import Foundation

/*struct ToDoTask {
    var title: String
    var isCompleted: Bool
}*/

struct ToDoTask: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
}

struct ToDoResponse: Codable {
    var todos: [ToDoTask]
}
