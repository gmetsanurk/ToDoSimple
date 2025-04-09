import UIKit

protocol Coordinator {
    func openHomeScreen()
    func openEditTaskScreen(onTaskSelected: @escaping EditTaskScreenHandler)
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
                    await presentedViewController.handleBackAction(completion: {
                        presentedViewController.dismiss(animated: true) {
                            self.window.rootViewController = HomeViewScreen(coordinator: self)
                            self.window.makeKeyAndVisible()
                        }
                    })
                }
            }
        } else {
            window.rootViewController = HomeViewScreen(coordinator: self)
            window.makeKeyAndVisible()
        }
    }

    func openEditTaskScreen(onTaskSelected: @escaping EditTaskScreenHandler) {
        let editTaskScreen = EditTaskScreen()
        editTaskScreen.onTaskSelected = onTaskSelected
        
        if let homeView = window.rootViewController as? AnyHomeView {
            homeView.present(screen: editTaskScreen)
        } else if window.rootViewController == nil {
            window.rootViewController = HomeViewScreen(coordinator: self)
            window.makeKeyAndVisible()
            (window.rootViewController as? AnyScreen)?.present(screen: editTaskScreen)
        }
    }
}
