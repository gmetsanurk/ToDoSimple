import UIKit

extension EditTaskViewController: UITextViewDelegate {
    
    func setupTaskTitleTextView() {
        let textView = taskTitleTextView
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        textView.delegate = self
    }
    
    func applyCustomTextStyle(for text: String) -> NSAttributedString {
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
        presenter?.updateTask(with: text)
        let attributedText = applyCustomTextStyle(for: text)
        textView.attributedText = attributedText
    }
    
}
