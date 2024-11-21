import UIKit
import CoreDataManager

class HomeTableViewCell: UITableViewCell {
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()
    
    let checkBox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupViews() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(checkBox)
        
        NSLayoutConstraint.activate([
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.widthAnchor.constraint(equalToConstant: 32),
            checkBox.heightAnchor.constraint(equalToConstant: 32),
            
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            taskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            taskLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }
    
    func configure(with task: ToDoTask) {
        let attributedText = applyCustomTextStyle(for: task.todo)
        taskLabel.attributedText = attributedText
        checkBox.isSelected = task.completed
    }
    
    private func applyCustomTextStyle(for text: String) -> NSAttributedString {
        let fullText = text as NSString
        let headerFont = UIFont.systemFont(ofSize: 18)
        let regularFont = UIFont.systemFont(ofSize: 14)
        let textColor = UIColor.label
        
        let attributedString = NSMutableAttributedString(string: fullText as String)
        
        if let firstLineEnd = text.range(of: "\n") {
            let firstLineRange = NSRange(firstLineEnd, in: text)
            
            attributedString.addAttribute(.font, value: headerFont, range: NSRange(location: 0, length: firstLineRange.location))
            attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: firstLineRange.location))
            
            let remainingRange = NSRange(location: firstLineRange.location, length: fullText.length - firstLineRange.location)
            attributedString.addAttribute(.font, value: regularFont, range: remainingRange)
            attributedString.addAttribute(.foregroundColor, value: textColor, range: remainingRange)
        } else {
            attributedString.addAttribute(.font, value: headerFont, range: NSRange(location: 0, length: fullText.length))
            attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: fullText.length))
        }
        
        return attributedString
    }
}
