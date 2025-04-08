import UIKit

extension HomeView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getCurrentTasks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = presenter.getCurrentTasks()[indexPath.row]
        cell.configure(with: task)
        
        cell.selectionStyle = .none
        
        let action = UIAction { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.presenter.toggleTaskCompletion(at: indexPath.row)
            let updatedTask = self.presenter.getCurrentTasks()[indexPath.row]
            
            cell.configure(with: updatedTask)
            
            Task {
                do {
                    self.presenter.handleSave(forOneTask: updatedTask)
                    print("Task saved successfully (checkBox action)")
                }
            }
        }
        
        cell.checkBox.addAction(action, for: .touchUpInside)
        applyLongGestureRecognizer(for: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteTask(at: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.updateTodosCountForTaskCountLabel()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = presenter.getCurrentTasks()[indexPath.row]
        self.showEditTaskViewController(for: task)
    }
}
