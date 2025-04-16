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
        DispatchQueue.main.async {
            if let someScreen = self.window.rootViewController, let presentedViewController = someScreen.presentedViewController as? EditTaskViewController {
                Task {
                    presentedViewController.dismiss(animated: true) {
                        self.window.rootViewController = HomeViewScreen(coordinator: self)
                        self.window.makeKeyAndVisible()
                    }
                }
            } else {
                self.window.rootViewController = HomeViewScreen(coordinator: self)
                self.window.makeKeyAndVisible()
            }
        }
    }
    
    func openEditTaskScreen(with task: ToDoTask, onTaskSelected: @escaping EditTaskScreenHandler) {
        let editTaskScreen = EditTaskScreen()
        editTaskScreen.onTaskSelected = onTaskSelected
        
        if let homeView = window.rootViewController as? AnyHomeView {
            homeView.present(screen: editTaskScreen)
            editTaskScreen.presenter?.configure(with: task)
        } else if window.rootViewController == nil {
            window.rootViewController = HomeViewScreen(coordinator: self)
            window.makeKeyAndVisible()
            (window.rootViewController as? AnyScreen)?.present(screen: editTaskScreen)
            editTaskScreen.presenter?.configure(with: task)
        }
    }
    
    func openAlert(onAdd: @escaping (String?) -> Void) {
        let newTaskTitle = NSLocalizedString("home_screen.new_task_title", comment: "New task alert controller")
        let newTaskMessageBody = NSLocalizedString("home_screen.new_task_message", comment: "New task message body")
        let addTitle = NSLocalizedString("home_screen.new_task_add", comment: "New task add message")
        let cancelTitle = NSLocalizedString("home_screen.new_task_cancel", comment: "New task cancel message")
        
        let alert = UIAlertController(title: newTaskTitle, message: newTaskMessageBody, preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: addTitle, style: .default) { _ in
            onAdd(alert.textFields?.first?.text)
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        let controller = window.rootViewController
        DispatchQueue.main.async {
            controller?.present(alert, animated: true)
        }
    }
}
