import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = "To-Do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.addTask()
        })
        
        setupSearchBar()
        presenter.handleImportTodos()
    }
    
    
    func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) {[weak self] _ in
            if let taskTitle = alert.textFields?.first?.text , !taskTitle.isEmpty {
                let newTask = ToDoTask(id: 1, todo: taskTitle, completed: false, userId: 1)
                self?.todos.append(newTask)
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
            self?.todos[indexPath.row].completed.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
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
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = todos[indexPath.row]
        let editTaskVC = EditTaskViewController()
        editTaskVC.task = task
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
}

extension HomeView: UISearchBarDelegate {
    
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

extension HomeView: AnyHomeView {
    func present(screen: AnyScreen) {
        if let screenController = screen as? (UIViewController & AnyScreen) {
            self.presentController(screen: screenController)
        }
    }
    
    func fetchTodos(for todoTask: [ToDoTask]) {
        self.todos = todoTask
        self.tableView.reloadData()
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