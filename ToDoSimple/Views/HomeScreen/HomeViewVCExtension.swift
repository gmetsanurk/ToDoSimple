import UIKit
import CoreDataManager

extension HomeView {
    
    func setupUI() {
        setupTitleLabel()
        setupSearchBar()
        setupTableView()
        setupBottomToolbar()
        setupConstraints()
    }
    
    func setupListOfTodos() {
        Task { [weak self] in
            await self?.presenter.chooseLocalOrRemoteTodos()
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.text = NSLocalizedString("home_screen.todo_title", comment: "Todo title")
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = NSLocalizedString("home_screen.search_bar", comment: "Search bar")
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = false
        view.addSubview(searchBar)
    }
    
    private func setupTableView() {
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    private func setupBottomToolbar() {
        let addTaskButton = UIBarButtonItem(systemItem: .compose, primaryAction: UIAction { [weak self] _ in
            self?.addTask()
        })
        addTaskButton.width = 44
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        updateTodosCountForTaskCountLabel()
        taskCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        taskCountLabel.textAlignment = .center
        let taskCountItem = UIBarButtonItem(customView: taskCountLabel)
        
        taskCountLabel.adjustsFontSizeToFitWidth = true
        taskCountLabel.minimumScaleFactor = 0.5
        
        bottomToolbar.setItems([flexibleSpace, taskCountItem, flexibleSpace, addTaskButton], animated: false)
        view.addSubview(bottomToolbar)
    }
    
    func addTask() {
        coordinator.openAlert { [weak self] firstText in
            guard let self = self,
                  let taskTitle = firstText,
                  !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            Task { [weak self] in
                await self?.presenter.addTask(with: taskTitle) {
                    self?.reloadTasks()
                    self?.updateTodosCountForTaskCountLabel()
                }
            }
        }
    }
    
    func updateTodosCountForTaskCountLabel() {
        let taskMessageBody = NSLocalizedString("home_screen.tasks", comment: "Task count label")
        self.taskCountLabel.text = "\(self.presenter.todosCount) \(taskMessageBody)"
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
        let shareTitle = NSLocalizedString("home_screen.share_title", comment: "Share alertController title")
        let messageBody = NSLocalizedString("home_screen.message_body", comment: "alertController message")
        
        let alertController = UIAlertController(title: shareTitle, message: messageBody, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: NSLocalizedString("home_screen.edit", comment: "Edit button"), style: .default) { [weak self] _ in
            self?.showEditTaskViewController(for: task)
        }
        
        let shareAction = UIAlertAction(title: NSLocalizedString("home_screen.share", comment: "Share button"), style: .default) { [weak self ]_ in
            self?.shareTask(task)
        }
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("home_screen.delete", comment: "Delete button"), style: .destructive) { [weak self] _ in
            self?.presenter.deleteTask(at: indexPath.row) {
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.updateTodosCountForTaskCountLabel()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("home_screen.cancel", comment: "Cancel button"), style: .cancel)
        
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
        coordinator.openEditTaskScreen(with: task, onTaskSelected: { [weak self] updatedTask in
            self?.presenter.updateTaskWithTitle(at: task.id, with: updatedTask.todo)
            self?.reloadTasks()
        })
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: AppGeometry.HomeScreen.titleLabelHeight),
            
            // Search bar
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: AppGeometry.HomeScreen.searchBarHeight),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            
            // Bottom toolbar
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: AppGeometry.HomeScreen.bottomToolbarHeight)
        ])
    }
}

