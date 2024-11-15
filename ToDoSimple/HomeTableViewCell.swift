import UIKit

class HomeTableViewCell: UITableViewCell {
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(checkBox)
        
        NSLayoutConstraint.activate([
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.widthAnchor.constraint(equalToConstant: 32),
            checkBox.heightAnchor.constraint(equalToConstant: 32),
            
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            taskLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    func configure(with task: ToDoTask) {
        taskLabel.text = task.title
        checkBox.isSelected = task.isCompleted
    }
}
