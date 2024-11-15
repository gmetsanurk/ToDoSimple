import UIKit

class HomeTableViewController: UITableViewController {
    
    var tasks = [ToDoTask(title: "Buy something", isCompleted: false),
                 ToDoTask(title: "Do the dishes", isCompleted: true),
                 ToDoTask(title: "Read a book", isCompleted: false)]
    
    let cellIdentifier = "ToDoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = "To-Do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.addTask()
        })
    }
    
    func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) {[weak self] _ in
            if let taskTitle = alert.textFields?.first?.text , !taskTitle.isEmpty {
                let newTask = ToDoTask(title: taskTitle, isCompleted: false)
                self?.tasks.append(newTask)
                self?.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
                
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        
        let action = UIAction { [weak self] _ in
            self?.tasks[indexPath.row].isCompleted.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.checkBox.addAction(action, for: .touchUpInside)
            
        return cell
    }
    
    func toggleTaskCompletion(_ sender: UIButton) {
        let taskIndex = sender.tag
        tasks[taskIndex].isCompleted.toggle()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let editTaskVC = EditTaskViewController()
        editTaskVC.task = task
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
}
