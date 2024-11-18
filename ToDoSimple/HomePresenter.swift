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
    
    let todosImportManager = TodosImportManager()
    
    func handleImportTodos() {
        todosImportManager.getTodos{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let succeedResult):
                    self?.view.fetchTodos(for: succeedResult)
                case .failure(let error):
                    print("Failed to get todos: \(error)")
                }
            }
        }
    }
    
    func handleFilterTodos(for todos: [ToDoTask], query: String, completion: @escaping ([ToDoTask]) -> Void) {
        DispatchQueue.main.async {
            let filteredTodos = todos.filter { task in
                task.todo.lowercased().contains(query.lowercased())
            }
            completion(filteredTodos)
        }
    }
}