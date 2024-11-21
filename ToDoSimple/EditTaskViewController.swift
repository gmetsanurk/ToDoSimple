import UIKit
import CoreDataManager

class EditTaskViewController: UIViewController, UITextViewDelegate {
    
    var task: ToDoTask?
    var onSave: ((String) -> Void)?
    
    private let taskTitleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backgroundColor
        setupViews()
        configureTask()
        createLeftBarButtonItem()
        taskTitleTextView.delegate = self
    }
    
    func setupViews() {
        view.addSubview(taskTitleTextView)
        
        NSLayoutConstraint.activate([
            taskTitleTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskTitleTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            taskTitleTextView.heightAnchor.constraint(equalTo: view.heightAnchor),
            taskTitleTextView.widthAnchor.constraint(equalTo: view.widthAnchor)
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
            print("Task saved successfully!")
        } catch {
            print("Failed to save task: \(error)")
        }
        
        onSave?(task.todo)
        navigationController?.popViewController(animated: true)
    }
    
    private func applyCustomTextStyle(for text: String) -> NSAttributedString {
        let fullText = text as NSString
        
        let headerFont = UIFont.boldSystemFont(ofSize: 24)
        let regularFont = UIFont.systemFont(ofSize: 18)
        let textColor = UIColor.label
        
        let attributedString = NSMutableAttributedString(string: fullText as String)
        
        let firstLineRange = (fullText.range(of: "\n") == NSRange(location: NSNotFound, length: 0)) ? NSRange(location: 0, length: fullText.length) : NSRange(location: 0, length: fullText.range(of: "\n").location)
        
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
