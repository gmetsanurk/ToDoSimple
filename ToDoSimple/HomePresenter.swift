import UIKit

protocol AnyScreen {
    func present(screen: AnyScreen)
}

extension AnyScreen where Self: UIViewController {
    func presentController(screen: AnyScreen & UIViewController) {
        self.present(screen, animated: true)
    }
}

protocol AnyHomeView: AnyScreen, AnyObject {
    
}

class HomePresenter {
    unowned var view: AnyHomeView!
    
    init(view: AnyHomeView) {
        self.view = view
    }
}

