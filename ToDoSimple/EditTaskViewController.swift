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
        setupViews()
        configureTask()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            primaryAction: UIAction { [weak self] _ in
                guard let self = self else { return }
                if let updatedTitle = self.taskTitleTextField.text {
                    self.onSave?(updatedTitle)
                }
                self.navigationController?.popViewController(animated: true)
            }
        )
    }
    
    func setupViews() {
        view.addSubview(taskTitleTextField)
        
        NSLayoutConstraint.activate([
            taskTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            taskTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureTask() {
        guard let task = task else {
            return
        }
        taskTitleTextField.text = task.todo
    }
    
    private func backButtonTapped() {
        if let updatedTitle = taskTitleTextField.text {
            onSave?(updatedTitle)
        }
        navigationController?.popViewController(animated: true)
    }
}
