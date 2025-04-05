import UIKit

protocol Coordinator {
    func openHomeScreen()
    func openEditTaskScreen(onTaskSelected: @escaping EditTaskScreenHandler)
}

private typealias HomeViewClass = HomeView
private typealias EditTaskClass = EditTaskViewController

struct UIKitCoordinator: Coordinator {
    unowned var window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func openHomeScreen() {
        if let someScreen = window.rootViewController, let presentedViewController = someScreen.presentedViewController as? EditTaskViewController {
            presentedViewController.dismiss(animated: true)
        } else {
            window.rootViewController = HomeViewClass(coordinator: self)
            window.makeKeyAndVisible()
        }
    }

    func openEditTaskScreen(onTaskSelected: @escaping EditTaskScreenHandler) {
        let editTaskScreen = EditTaskClass()
        editTaskScreen.onTaskSelected = onTaskSelected
        
        if let homeView = window.rootViewController as? AnyHomeView {
            homeView.present(screen: editTaskScreen)
        } else if window.rootViewController == nil {
            window.rootViewController = HomeViewClass(coordinator: self)
            window.makeKeyAndVisible()
            (window.rootViewController as? AnyScreen)?.present(screen: editTaskScreen)
        }
    }
}
