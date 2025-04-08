import UIKit
import CoreDataManager

extension HomeView {
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(toolbar)
        
        setupSearchBar()
        setupTableView()
        setupBottomToolbar()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
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
        
        toolbar.setItems([flexibleSpace, taskCountItem, flexibleSpace, addTaskButton], animated: false)
        
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

