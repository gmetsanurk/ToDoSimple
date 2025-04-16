import UIKit
import CoreDataManager

class HomeTableViewCell: UITableViewCell {
    weak var delegate: HomeViewCellsHandler?
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var checkBox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
        button.addAction(UIAction.init(handler: { [unowned self] _ in
            Task {
                await self.delegate?.onCellTapped(cell: self, indexPath: indexPath)
            }
        }), for: .primaryActionTriggered)
        return button
    }()
    
    private var indexPath: IndexPath!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with task: ToDoTask, delegate: HomeViewCellsHandler, indexPath: IndexPath) {
        let attributedText = applyCustomTextStyle(for: task.todo, isCompleted: task.completed)
        taskLabel.attributedText = attributedText
        checkBox.isSelected = task.completed
        self.delegate = delegate
        self.indexPath = indexPath
    }
    
    private func applyCustomTextStyle(for text: String, isCompleted: Bool) -> NSAttributedString {
        let fullText = text as NSString
        let headerFont = UIFont.systemFont(ofSize: 17)
        let regularFont = UIFont.systemFont(ofSize: 14)
        let headerColor = isCompleted ? UIColor.gray : UIColor.label
        let strikeThroughStyle = isCompleted ? NSUnderlineStyle.single.rawValue : 0
        
        let attributedString = NSMutableAttributedString(string: fullText as String)
        
        if let firstLineEnd = text.range(of: "\n") {
            let firstLineRange = NSRange(location: 0, length: text.distance(from: text.startIndex, to: firstLineEnd.lowerBound))
            
            // apply text style for first line in cell.
            attributedString.addAttribute(.font, value: headerFont, range: firstLineRange)
            attributedString.addAttribute(.foregroundColor, value: headerColor, range: firstLineRange)
            attributedString.addAttribute(.strikethroughStyle, value: strikeThroughStyle, range: firstLineRange)
            
            // apply text style for others lines in cell.
            let remainingRange = NSRange(location: firstLineRange.upperBound, length: fullText.length - firstLineRange.upperBound)
            attributedString.addAttribute(.font, value: regularFont, range: remainingRange)
            attributedString.addAttribute(.foregroundColor, value: headerColor, range: remainingRange)
        } else {
            // apply text style for cell with just header line.
            let fullRange = NSRange(location: 0, length: fullText.length)
            attributedString.addAttribute(.font, value: headerFont, range: fullRange)
            attributedString.addAttribute(.foregroundColor, value: headerColor, range: fullRange)
            attributedString.addAttribute(.strikethroughStyle, value: strikeThroughStyle, range: fullRange)
        }
        
        return attributedString
    }
    
    private func setupViews() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(checkBox)
        
        NSLayoutConstraint.activate([
            checkBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.widthAnchor.constraint(equalToConstant: 32),
            checkBox.heightAnchor.constraint(equalToConstant: 32),
            
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            taskLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }
    
}
