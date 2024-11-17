import UIKit

class HomeTableViewController: UITableViewController {
    
    var tasks = [ToDoTask(title: "Buy something", isCompleted: false),
                 ToDoTask(title: "Do the dishes", isCompleted: true),
                 ToDoTask(title: "Read a book", isCompleted: false)]
    
    var filteredTasks: [ToDoTask] = []
    var isSearching = false
    
    let cellIdentifier = "ToDoCell"
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Task"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = "To-Do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.addTask()
        })
        
        setupSearchBar()
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
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }
    
    private func filterTasks(for query: String) {
        filteredTasks = tasks.filter { task in
            task.title.lowercased().contains(query.lowercased())
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
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

extension HomeTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filterTasks(for: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        tableView.reloadData()
    }
}
