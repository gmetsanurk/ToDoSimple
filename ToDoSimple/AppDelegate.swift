import UIKit

protocol AnyTodosSource {
    
}

actor DependenciesContainer {
    private var todosSource: AnyTodosSource?

    func registerTodosSource(todosSource: AnyTodosSource?) {
        self.todosSource = todosSource
    }

    func resolveTodos() -> AnyTodosSource? {
        return todosSource
    }
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: UIKitCoordinator!
    
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupWindow()
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = UIKitCoordinator(window: window!)
        coordinator.openHomeScreen()
    }
}

