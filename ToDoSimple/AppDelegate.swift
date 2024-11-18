import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupWindow()
        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let homeVC = HomeView()
        let navigationController = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

