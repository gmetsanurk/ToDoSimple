import UIKit

class EditTaskViewController: UIViewController {
    
    var task: ToDoTask?
    var onSave: ((String) -> Void)?
    
    private let taskTitleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter task title"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    
}
