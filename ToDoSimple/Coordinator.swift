import UIKit
import CoreDataManager

protocol Coordinator {
    func openHomeScreen()
    func openEditTaskScreen(with task: ToDoTask, onTaskSelected: @escaping EditTaskScreenHandler)
    func openAlert(onAdd: @escaping (String?) -> Void)
}

private typealias HomeViewScreen = HomeView
private typealias EditTaskScreen = EditTaskViewController

struct UIKitCoordinator: Coordinator {
    
    unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func openHomeScreen() {
        if let someScreen = window.rootViewController, let presentedViewController = someScreen.presentedViewController as? EditTaskViewController {
            Task {
                do {
                    await presentedViewController.handleBackAction()
                    presentedViewController.dismiss(animated: true) {
                        self.window.rootViewController = HomeViewScreen(coordinator: self)
                        self.window.makeKeyAndVisible()
                    }
                }
            }
        } else {
            window.rootViewController = HomeViewScreen(coordinator: self)
            window.makeKeyAndVisible()
        }
    }
    
    func openEditTaskScreen(with task: ToDoTask, onTaskSelected: @escaping EditTaskScreenHandler) {
        let editTaskScreen = EditTaskScreen()
        editTaskScreen.onTaskSelected = onTaskSelected
        editTaskScreen.presenter?.configure(with: task)
        
        if let homeView = window.rootViewController as? AnyHomeView {
            homeView.present(screen: editTaskScreen)
        } else if window.rootViewController == nil {
            window.rootViewController = HomeViewScreen(coordinator: self)
            window.makeKeyAndVisible()
            (window.rootViewController as? AnyScreen)?.present(screen: editTaskScreen)
        }
    }
    
    func openAlert(onAdd: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            onAdd(alert.textFields?.first?.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        let controller = window.rootViewController
        DispatchQueue.main.async {
            controller?.present(alert, animated: true)
        }
    }
}
