import UIKit
import Dispatch
import CoreDataManager

protocol AnyScreen {
    func present(screen: AnyScreen)
}

extension AnyScreen where Self: UIViewController {
    func presentController(screen: AnyScreen & UIViewController) {
        self.present(screen, animated: true)
    }
}

protocol AnyHomeView: AnyScreen, AnyObject {
    func fetchTodosForAnyView(for todoTask: [ToDoTask])
    func reloadTasks()
}

class HomePresenter {
    
    var todos: [ToDoTask] = []
    
    var filteredTasks: [ToDoTask] = []
    var isSearching = false
    
    var todosCount: Int {
        return todos.count
    }
    
    unowned var view: AnyHomeView!
    let coordinator: Coordinator
    
    init(view: AnyHomeView, coordinator: Coordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    let todosRemoteManager = TodosRemoteManager()
    let todosCoreDataManager = CoreDataManager.shared
}

extension HomePresenter {
    
    func handleOpenEditTask(at index: Int, onTaskSelected: ((ToDoTask?) -> Void)?) {
        let taskToEdit = self.todos[index]
        coordinator.openEditTaskScreen(with: taskToEdit, onTaskSelected: { [weak self] updatedTask in
            self?.handleTaskSelected(updatedTask: updatedTask)
            self?.coordinator.openHomeScreen()
        })
    }
    
    func handleTaskSelected(updatedTask: ToDoTask) {
        if let index = todos.firstIndex(where: { $0.id == updatedTask.id }) {
            todos[index] = updatedTask
            updateTaskWithTitle(at: index, with: updatedTask.todo)
            self.view.fetchTodosForAnyView(for: todos)
            Task {
                await logger.log("Updated task successfully.")
            }
        }
    }
    
    func addTask(with title: String, completion: @escaping () -> Void) async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let id = await handleTaskID()
        let newTask = ToDoTask(id: id, todo: title, completed: false, userId: 1)
        
        todos.append(newTask)
        handleSave(forOneTask: newTask)
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func chooseLocalOrRemoteTodos() async {
        do {
            if await todosCoreDataManager.isEmptyTodos() {
                handleRemoteTodos()
            } else {
                let result = try await todosCoreDataManager.getTodos()
                await MainActor.run {
                    self.view.fetchTodosForAnyView(for: result)
                }
            }
        } catch {
            await logger.log("Error handling todos: \(error)")
        }
    }
    
    func handleRemoteTodos() {
        todosRemoteManager.getTodos{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let succeedResult):
                    self?.view.fetchTodosForAnyView(for: succeedResult)
                    Task {
                        try await self?.todosCoreDataManager.save(forMultipleTasks: succeedResult)
                    }
                case .failure(let error):
                    Task {
                        await logger.log("Failed to get todos: \(error)")
                    }
                }
            }
        }
    }
    
    func handleFilterTodos(for todos: [ToDoTask], query: String, completion: @escaping ([ToDoTask]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredTodos = todos.filter { task in
                task.todo.lowercased().contains(query.lowercased())
            }
            DispatchQueue.main.async {
                completion(filteredTodos)
            }
        }
    }
    
    func handleSave(forOneTask task: ToDoTask) {
        Task { [weak self] in
            try await self?.todosCoreDataManager.save(forOneTask: task)
            await logger.log("Successful save action (HomePresenter).")
        }
    }
    
    func handleDelete(forOneTask task: ToDoTask) {
        Task { [weak self] in
            try await self?.todosCoreDataManager.delete(task: task)
        }
    }
    
    func handleTaskID() async -> Int {
        do {
            return try await self.todosCoreDataManager.getNextID()
        } catch {
            await logger.log("ID getting error: \(error)")
            return 1
        }
    }
}

extension HomePresenter {
    func getCurrentTasks() -> [ToDoTask] {
        return isSearching ? filteredTasks : todos
    }
    
    func updateTaskWithTitle(at index: Int, with newTitle: String) {
        if isSearching {
            filteredTasks[index].todo = newTitle
            if let originalIndex = todos.firstIndex(where: {$0.id == filteredTasks[index].id }) {
                todos[originalIndex].todo = newTitle
            }
        } else {
            todos[index].todo = newTitle
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            guard let taskToSave = self.todos[safe: index] else { return }
            self.handleSave(forOneTask: taskToSave)
        }
    }
    
    func deleteTask(at index: Int, completion: @escaping () -> Void) {
        let taskToDelete = getCurrentTasks()[index]
        
        if isSearching {
            if let originalIndex = todos.firstIndex(where: { $0.id == taskToDelete.id}) {
                todos.remove(at: originalIndex)
            }
            filteredTasks.remove(at: index)
        } else {
            todos.remove(at: index)
        }
        
        Task { [weak self] in
            self?.handleDelete(forOneTask: taskToDelete)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}

extension HomePresenter {
    
    func toggleTaskCompletion(at index: Int) {
        todos[index].completed.toggle()
        handleSave(forOneTask: todos[index])
    }
    
    func toggleTaskCompletion(at index: Int, completion: @escaping () -> Void) {
        var task = isSearching ? filteredTasks[index] : todos[index]
        task.completed.toggle()
        
        Task { [weak self] in
            self?.handleSave(forOneTask: task)
            completion()
        }
    }
    
    func handleLongPress(at indexPath: IndexPath, completion: @escaping (ToDoTask) -> Void) {
        let task = todos[indexPath.row]
        completion(task)
    }
    
    func filterTasks(for query: String, completion: @escaping ([ToDoTask]) -> Void) {
        let result = todos.filter { $0.todo.lowercased().contains(query.lowercased()) }
        completion(result)
    }
    
    func clearSearch() {
        self.filteredTasks = []
        self.isSearching = false
    }
    
}
