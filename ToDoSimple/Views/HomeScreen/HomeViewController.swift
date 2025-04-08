import UIKit
import CoreDataManager

struct Colors {
    static let backgroundColor = UIColor.systemBackground
}

class HomeView: UIViewController {
    
    let cellIdentifier = "ToDoCell"
    let coordinator: Coordinator
    lazy var presenter: HomePresenter = {
        return HomePresenter(view: self, coordinator: coordinator)
    }()
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        presenter = HomePresenter(view: self, coordinator: coordinator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView = UITableView()
    let titleLabel = UILabel()
    let bottomToolbar = UIToolbar()
    let searchBar = UISearchBar()
    let taskCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        
        setupUI()
        setupListOfTodos()
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
