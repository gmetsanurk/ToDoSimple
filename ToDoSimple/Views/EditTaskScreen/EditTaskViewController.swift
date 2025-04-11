import UIKit
import Combine
import CoreDataManager

typealias EditTaskScreenHandler = (ToDoTask) -> Void?

class EditTaskViewController: UIViewController, AnyTaskView {
    
    var onTaskSelected: EditTaskScreenHandler?
    private var keyboardWillShowNotificationCancellable: AnyCancellable?
    private var keyboardWillHideNotificationCancellable: AnyCancellable?
    let taskTitleTextView = UITextView()
    
    var presenter: EditTaskPresenter?
    var leftBarButtonItemAction: (() -> Void)?
    
    unowned var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        createBackButton()
        createKeyboard()
        setupTaskTitleTextView()
        view.addSubview(taskTitleTextView)
        view.addSubview(backButton)
        setupConstraints()
        
        presenter = EditTaskPresenter(view: self, onTaskSelected: { updatedTask in
            self.onTaskSelected?(updatedTask)
        })
        
        if let task = presenter?.currentTask {
            presenter?.configure(with: task)
        }
    }
    
}

extension EditTaskViewController {
    
    private func createBackButton() {
        backButton = {
            let result = UIButton(
                type: .system,
                primaryAction: UIAction { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    Task { [weak self] in
                        await self?.handleBackAction()
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            )
            result.setTitle("Back", for: .normal)
            view.addSubview(result)
            return result
        }()
    }
    
    func configureTask(with task: ToDoTask?) {
        guard let task = task else {
            return
        }
        let attributedText = applyCustomTextStyle(for: task.todo)
        taskTitleTextView.attributedText = attributedText
        presenter?.updateTask(with: task.todo)
    }
    
    func handleBackAction() async {
        await presenter?.handleBackAction() {
            self.dismiss(animated: true, completion: nil)
        }
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

extension EditTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        presenter?.updateTask(with: text)
    }
    
    private func setupTaskTitleTextView() {
        let textView = taskTitleTextView
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
    
    /*func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
                
        let attributedText = applyCustomTextStyle(for: text)
        textView.attributedText = attributedText
    }*/
    
}

extension EditTaskViewController: AnyScreen {
    func present(screen: any AnyScreen) {
        if let screenController = screen as? (UIViewController & AnyScreen) {
            self.presentController(screen: screenController)
        }
    }
}
