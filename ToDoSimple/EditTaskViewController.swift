import UIKit
import CoreDataManager

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
        createLeftBarButtonItem()
    }
    
    func setupViews() {
        view.addSubview(taskTitleTextField)
        
        NSLayoutConstraint.activate([
            taskTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            taskTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func createLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            primaryAction: UIAction { [weak self] _ in
                guard let self = self else {
                    return
                }
                Task {
                    await self.handleBackAction()
                }
            }
        )
    }
    
    private func configureTask() {
        guard let task = task else {
            return
        }
        taskTitleTextField.text = task.todo
    }
    
    private func handleBackAction() async {
        guard var task = task else {
            return
        }
        
        if let updatedTitle = taskTitleTextField.text, !updatedTitle.isEmpty {
            task.todo = updatedTitle
        }
        
        do {
            try await CoreDataManager.shared.save(forOneTask: task)
            print("Task saved successfully!")
        } catch {
            print("Failed to save task: \(error)")
        }
        
        onSave?(task.todo)
        navigationController?.popViewController(animated: true)
    }
}
