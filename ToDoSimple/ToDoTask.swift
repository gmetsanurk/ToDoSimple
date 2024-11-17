import Foundation

/*struct ToDoTask {
    var title: String
    var isCompleted: Bool
}*/

struct ToDoTask: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct ToDoResponse: Codable {
    let todos: [ToDoTask]
}
