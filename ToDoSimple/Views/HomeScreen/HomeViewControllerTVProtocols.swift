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
                self.updateTodosCountForTaskCountLabel()
            }
        }
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = presenter.getCurrentTasks()[indexPath.row]
        
        coordinator.openEditTaskScreen(with: task, onTaskSelected: { [weak self] updatedTask in
            self?.presenter.updateTaskTitle(at: task.id, newTitle: updatedTask.todo)
            self?.tableView.reloadData()
        })
    }*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = presenter.getCurrentTasks()[indexPath.row]
        presenter.handleOpenEditTask(onTaskSelected: { [weak self] updatedTask in
            if let updatedTitle = updatedTask?.todo {
                self?.presenter.updateTaskTitle(at: task.id, newTitle: updatedTitle)
                self?.tableView.reloadData()
            }
        })
    }}
