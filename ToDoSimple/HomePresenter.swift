import UIKit
import Dispatch

protocol AnyScreen {
    func present(screen: AnyScreen)
}

extension AnyScreen where Self: UIViewController {
    func presentController(screen: AnyScreen & UIViewController) {
        self.present(screen, animated: true)
    }
}

protocol AnyHomeView: AnyScreen, AnyObject {
    func fetchTodos(for todoTask: [ToDoTask])
}

class HomePresenter {
    unowned var view: AnyHomeView!
    
    init(view: AnyHomeView) {
        self.view = view
    }
    
    let todosRemoteManager = TodosRemoteManager()
<<<<<<< HEAD
    let todosCoreDataManager = CoreDataManager.shared
    
    func handleLocalOrRemoteTodos() async {
        do {
            if await todosCoreDataManager.isEmptyTodos() {
                handleRemoteTodos()
            } else {
                let result = try await todosCoreDataManager.getTodos()
                await MainActor.run {
                    self.view.fetchTodos(for: result)
                }
            }
        } catch {
            print("Error handling todos: \(error)")
        }
    }
    
    func handleRemoteTodos() {
=======
    
    func handleImportTodos() {
>>>>>>> 60edfe2 (do coreDataManager)
        todosRemoteManager.getTodos{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let succeedResult):
                    self?.view.fetchTodos(for: succeedResult)
                    Task {
                        try await self?.todosCoreDataManager.save(for: succeedResult)
                    }
                case .failure(let error):
                    print("Failed to get todos: \(error)")
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
}
