import UIKit

extension HomeView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.displayTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = presenter.displayTodos[indexPath.row]
        cell.configure(with: task, delegate: self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        // cell.checkBox.addAction(action, for: .primaryActionTriggered)
        applyLongGestureRecognizer(for: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteTask(at: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                DispatchQueue.main.async {
                    self.updateTodosCountForTaskCountLabel()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realIndex = presenter.todos.count - 1 - indexPath.row
        let task = presenter.todos[realIndex]
        presenter.handleOpenEditTask(at: realIndex, onTaskSelected: { [weak self] updatedTask in
            if let updatedTask = updatedTask {
                self?.presenter.updateTaskWithTitle(at: indexPath.row, with: updatedTask.todo)
                self?.tableView.reloadData()
            }
        })
    }
}
