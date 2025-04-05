import UIKit
import CoreDataManager

struct Colors {
    static let backgroundColor = UIColor.systemBackground
}

class HomeView: UITableViewController {
    
    private let coordinator: Coordinator
    private lazy var presenter: HomePresenter = {
        return HomePresenter(view: self, coordinator: coordinator)
    }()
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        Task { [weak self] in
            await self?.presenter.chooseLocalOrRemoteTodos()
        }
    }
    
    func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let taskTitle = alert.textFields?.first?.text,
                  !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            Task { [weak self] in
                await self?.presenter.addTask(with: taskTitle) {
                    self?.tableView.reloadData()
                    self?.updateTodosCountForTaskCountLabel()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
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
        return presenter.getCurrentTasks().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let task = presenter.getCurrentTasks()[indexPath.row]
        cell.configure(with: task)
        
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteTask(at: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.updateTodosCountForTaskCountLabel()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = presenter.getCurrentTasks()[indexPath.row]
        self.showEditTaskViewController(for: task)
    }
}

extension HomeView {
    
    func updateTodosCountForTaskCountLabel() {
        taskCountLabel.text = "\(presenter.todosCount) tasks"
    }
    
    func applyLongGestureRecognizer(for cell: UITableViewCell) {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        
        let location = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        presenter.handleLongPress(at: indexPath) { task in
            self.showTaskActions(for: task, at: indexPath)
        }
    }
    
    private func showTaskActions(for task: ToDoTask, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Share Task", message: "Would you like to share this task?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.showEditTaskViewController(for: task)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self ]_ in
            self?.shareTask(task)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.presenter.deleteTask(at: indexPath.row) {
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.updateTodosCountForTaskCountLabel()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(editAction)
        alertController.addAction(shareAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func shareTask(_ task: ToDoTask) {
        let activityController = UIActivityViewController(activityItems: [task.todo], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    func showEditTaskViewController(for task: ToDoTask) {
        coordinator.openEditTaskScreen(onTaskSelected: { [weak self] updatedTask in
            self?.presenter.updateTaskTitle(at: task.id, newTitle: updatedTask.todo)
            self?.tableView.reloadData()
        })
    }
}

extension HomeView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        presenter.clearSearch()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.isSearching = !searchText.isEmpty
        presenter.filterTasks(for: searchText) {[weak self] filteredTasks in
            guard let self = self else { return }
            self.presenter.filteredTasks = filteredTasks
            self.tableView.reloadData()
        }
    }
}

extension HomeView: AnyHomeView {
    func present(screen: AnyScreen) {
        if let screenController = screen as? (UIViewController & AnyScreen) {
            self.presentController(screen: screenController)
        }
    }
    
    func fetchTodosForAnyView(for todoTask: [ToDoTask]) {
        self.presenter.todos = todoTask
        self.tableView.reloadData()
        updateTodosCountForTaskCountLabel()
    }
    
    func reloadTasks() {
        tableView.reloadData()
    }
}
