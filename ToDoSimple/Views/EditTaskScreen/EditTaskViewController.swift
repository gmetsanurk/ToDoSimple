import UIKit
import Combine
import CoreDataManager

typealias EditTaskScreenHandler = (ToDoTask) -> Void?

class EditTaskViewController: UIViewController, AnyTaskView {
    
    var onTaskSelected: EditTaskScreenHandler?
    var task: ToDoTask?
    private var keyboardWillShowNotificationCancellable: AnyCancellable?
    private var keyboardWillHideNotificationCancellable: AnyCancellable?
    private let taskTitleTextView = UITextView()
    
    var leftBarButtonItemAction: (() -> Void)?
    
    var backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        configureTask()
        createLeftBarButtonItem()
        handleTaskTitleTextView()
        createKeyboard()
        setupConstraints()
        
        view.addSubview(taskTitleTextView)
    }
    
}

extension EditTaskViewController {
    
    private func createLeftBarButtonItem() {
        backButton = UIButton(
            type: .system,
            primaryAction: UIAction { [weak self] _ in
                guard let self = self else {
                    return
                }
                Task { [weak self] in
                    await self?.handleBackAction()
                }
            })

        view.addSubview(backButton)
    }
    
    private func configureTask() {
        guard let task = task else {
            return
        }
        let attributedText = applyCustomTextStyle(for: task.todo)
        taskTitleTextView.attributedText = attributedText
    }
    
    private func handleBackAction() async {
        guard var task = task else {
            return
        }
        
        if let updatedTitle = taskTitleTextView.text, !updatedTitle.isEmpty {
            task.todo = updatedTitle
        }
        
        do {
            try await CoreDataManager.shared.save(forOneTask: task)
            print("Task saved successfully (from handleBack action)")
        } catch {
            print("Failed to save task: \(error)")
        }
        
        onTaskSelected?(task)
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
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            taskTitleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            taskTitleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskTitleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskTitleTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }

}

extension EditTaskViewController: UITextViewDelegate {
    
    private func handleTaskTitleTextView() {
        let textView = taskTitleTextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        textView.delegate = self
    }
    
    private func applyCustomTextStyle(for text: String) -> NSAttributedString {
        let fullText = text as NSString
        
        let headerFont = UIFont.boldSystemFont(ofSize: 24)
        let regularFont = UIFont.systemFont(ofSize: 18)
        let textColor = UIColor.label
        
        let attributedString = NSMutableAttributedString(string: fullText as String)
        
        let firstLineRange: NSRange
        if let firstLineEndIndex = text.firstIndex(of: "\n") {
            firstLineRange = NSRange(text.startIndex..<firstLineEndIndex, in: text)
        } else {
            firstLineRange = NSRange(location: 0, length: text.count)
        }
        
        attributedString.addAttribute(.font, value: headerFont, range: firstLineRange)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: firstLineRange)
        
        let remainingTextRange = NSRange(location: firstLineRange.length, length: fullText.length - firstLineRange.length)
        attributedString.addAttribute(.font, value: regularFont, range: remainingTextRange)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: remainingTextRange)
        
        return attributedString
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        let attributedText = applyCustomTextStyle(for: text)
        textView.attributedText = attributedText
    }
    
}

extension EditTaskViewController: AnyScreen {
    func present(screen: any AnyScreen) {}
}
