import UIKit
import CoreDataManager

struct Colors {
    static let backgroundColor = UIColor.systemBackground
}

class HomeView: UIViewController {
    
    let coordinator: Coordinator
    lazy var presenter: HomePresenter = {
        return HomePresenter(view: self, coordinator: coordinator)
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellIdentifier = "ToDoCell"
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        presenter = HomePresenter(view: self, coordinator: coordinator)
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To-Do List"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    let searchBar: UISearchBar = {
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
        
        setupUI()
        
        Task { [weak self] in
            await self?.presenter.chooseLocalOrRemoteTodos()
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
