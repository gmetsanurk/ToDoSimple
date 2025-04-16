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
            result.setTitle(NSLocalizedString("edit_task.back", comment: "Back button"), for: .normal)
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
        let doneButton = UIBarButtonItem(title: NSLocalizedString("edit_task.done", comment: "Done keyboard button"), style: .done, target: self, action: #selector(doneButtonTapped))
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
            // Back button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppGeometry.EditTaskScreen.backButtonLeftMargin),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppGeometry.EditTaskScreen.backButtonTopMargin),
            backButton.widthAnchor.constraint(equalToConstant: AppGeometry.EditTaskScreen.backButtonWidth),
            backButton.heightAnchor.constraint(equalToConstant: AppGeometry.EditTaskScreen.backButtonHeight),
            
            //Task title textView
            taskTitleTextView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: AppGeometry.EditTaskScreen.textViewTopMargin),
            taskTitleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppGeometry.EditTaskScreen.textViewHorizontalMargin),
            taskTitleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppGeometry.EditTaskScreen.textViewHorizontalMargin),
            taskTitleTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AppGeometry.EditTaskScreen.textViewBottomMargin)
        ])
    }
}
