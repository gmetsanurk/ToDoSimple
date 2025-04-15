import UIKit
import CoreDataManager

extension EditTaskViewController {
    
    func setupPresenter() {
        presenter = EditTaskPresenter(view: self, onTaskSelected: { updatedTask in
            self.onTaskSelected?(updatedTask)
        })
    }
    
    func createBackButton() {
        backButton = {
            let result = UIButton(
                type: .system,
                primaryAction: UIAction { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    Task { [weak self] in
                        self?.handleBackAction()
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            )
            result.setTitle("Back", for: .normal)
            view.addSubview(result)
            return result
        }()
    }
    
    func handleBackAction() {
        presenter?.handleBackAction()
    }
    
    func configureTask(with task: ToDoTask?) {
        guard let task = task else {
            return
        }
        let attributedText = applyCustomTextStyle(for: task.todo)
        taskTitleTextView.attributedText = attributedText
        presenter?.updateTask(with: task.todo)
    }
    
    func createKeyboard() {
        keyboardWillShowNotificationCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard self != nil else { return }
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let keyboardHeight = keyboardFrame.height
                }
            }
        
        keyboardWillHideNotificationCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.view.frame.origin.y = 0.0
            }
        createDoneButtonOnKeyboard()
    }
    
    func createDoneButtonOnKeyboard() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("home_view.done", comment: "Done keyboard button"), style: .done, target: self, action: #selector(doneButtonTapped))
        //doneButton.accessibilityIdentifier = AccessibilityIdentifiers.EditTaskViewController.keyboardDone
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [flexSpace, doneButton]
        taskTitleTextView.inputAccessoryView = toolBar
    }
    
    @objc private func doneButtonTapped() {
        taskTitleTextView.resignFirstResponder()
    }
    
    func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        taskTitleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            taskTitleTextView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            taskTitleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskTitleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskTitleTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}
