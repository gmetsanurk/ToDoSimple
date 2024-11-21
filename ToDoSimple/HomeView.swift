import UIKit
import CoreDataManager

struct Colors {
    static let backgroundColor = UIColor.white
}

class HomeView: UITableViewController {
    
    private lazy var presenter = HomePresenter(view: self)
    
    var todos: [ToDoTask] = []
    
    var filteredTasks: [ToDoTask] = []
    var isSearching = false
    
    let cellIdentifier = "ToDoCell"
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Task"
        return searchBar
    }()
    
    let taskCountLabel: UILabel = {
        let uILabel = UILabel()
        return uILabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = "To-Do List"

        setupSearchBar()
        setupBottomToolbar()
        
        
        Task {
            await presenter.handleLocalOrRemoteTodos()
        }
    }
    
    func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            Task {
                guard let self = self,
                      let taskTitle = alert.textFields?.first?.text,
                      !taskTitle.isEmpty else { return }
                let theIDNumber = await self.presenter.handleTaskID()
                
                let newTask = ToDoTask(id: theIDNumber, todo: taskTitle, completed: false, userId: 1)
                self.todos.append(newTask)
                self.tableView.reloadData()
                
                
                do {
                    self.presenter.handleSave(forOneTask: newTask)
                    self.updateTodosCountForTaskCountLabel()
                    print("Task saved successfully.")
                }
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
        searchBar.showsCancelButton = false
        tableView.tableHeaderView = searchBar
    }
    
    private func setupBottomToolbar() {
        let addTaskButton = UIBarButtonItem(systemItem: .compose, primaryAction: UIAction { [weak self] _ in
            self?.addTask()
        })
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        updateTodosCountForTaskCountLabel()
        taskCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        taskCountLabel.textAlignment = .center
        let taskCountItem = UIBarButtonItem(customView: taskCountLabel)
        
        taskCountLabel.adjustsFontSizeToFitWidth = true
        taskCountLabel.minimumScaleFactor = 0.5
        
        setToolbarItems([flexibleSpace, taskCountItem, flexibleSpace, addTaskButton], animated: false)
        navigationController?.isToolbarHidden = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = isSearching ? filteredTasks[indexPath.row] : todos[indexPath.row]
        cell.configure(with: task)
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            self.todos[indexPath.row].completed.toggle()
            let updatedTask = self.todos[indexPath.row]
            
            cell.configure(with: self.todos[indexPath.row])
            
            Task {
                do {
                    self.presenter.handleSave(forOneTask: updatedTask)
                    print("Task saved successfully.")
                }
            }
        }
        
        
        cell.checkBox.addAction(action, for: .touchUpInside)
        
        return cell
    }
    
    func toggleTaskCompletion(_ sender: UIButton) {
        let taskIndex = sender.tag
        todos[taskIndex].completed.toggle()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = todos[indexPath.row]
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            Task {
                do {
                    self.presenter.handleDelete(forOneTask: taskToDelete)
                    self.updateTodosCountForTaskCountLabel()
                    print("Task deleted successfully.")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = todos[indexPath.row]
        let editTaskVC = EditTaskViewController()
        editTaskVC.task = task
        
        editTaskVC.onSave = { [weak self] updatedTitle in
            guard let self = self else {
                return
            }
            
            self.todos[indexPath.row].todo = updatedTitle
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
            Task {
                do {
                    self.presenter.handleSave(forOneTask: self.todos[indexPath.row])
                    print("Task updated successfully.")
                }
            }
        }
        
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
}

extension HomeView {
    
    func updateTodosCountForTaskCountLabel() {
        taskCountLabel.text = "\(todos.count) tasks"
    }
    
}

extension HomeView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        isSearching = false
        filteredTasks = []
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredTasks = []
        } else {
            isSearching = true
            filteredTasks = todos.filter { $0.todo.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension HomeView: AnyHomeView {
    func present(screen: AnyScreen) {
        if let screenController = screen as? (UIViewController & AnyScreen) {
            self.presentController(screen: screenController)
        }
    }
    
    func fetchTodosForAnyView(for todoTask: [ToDoTask]) {
        self.todos = todoTask
        self.tableView.reloadData()
        updateTodosCountForTaskCountLabel()
    }
    
    private func filterTasks(for query: String) {
        presenter.handleFilterTodos(for: todos, query: query) { result in
            DispatchQueue.main.async {
                self.filteredTasks = result
                self.tableView.reloadData()
            }
        }
    }
}
