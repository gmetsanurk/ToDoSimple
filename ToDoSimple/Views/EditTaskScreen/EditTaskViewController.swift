import UIKit
import Combine
import CoreDataManager

typealias EditTaskScreenHandler = (ToDoTask) -> Void?

class EditTaskViewController: UIViewController, AnyTaskView {
    
    var onTaskSelected: EditTaskScreenHandler?
    var keyboardWillShowNotificationCancellable: AnyCancellable?
    var keyboardWillHideNotificationCancellable: AnyCancellable?
    let taskTitleTextView = UITextView()
    
    var presenter: EditTaskPresenter?
    var leftBarButtonItemAction: (() -> Void)?
    
    unowned var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        setupPresenter()
        
        createBackButton()
        createKeyboard()
        setupTaskTitleTextView()
        view.addSubview(taskTitleTextView)
        view.addSubview(backButton)
        setupConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskTitleTextView.becomeFirstResponder()
    }
    
}

extension EditTaskViewController: AnyScreen {
    func present(screen: any AnyScreen) {
        if let screenController = screen as? (UIViewController & AnyScreen) {
            self.presentController(screen: screenController)
        }
    }
}
