import UIKit
import CoreDataManager

actor EventsLogger {
    func log(_ message: @autoclosure () -> String) {
        #if LOGS_ENABLED
        print(message())
        #endif
    }
}
let logger = EventsLogger()

struct Colors {
    static let backgroundColor = UIColor.systemBackground
}

protocol HomeViewCellsHandler: AnyObject {
    func onCellTapped(cell: HomeTableViewCell, indexPath: IndexPath)
}

class HomeView: UIViewController, HomeViewCellsHandler {
    
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
    
    func onCellTapped(cell: HomeTableViewCell, indexPath: IndexPath) {
        self.presenter.toggleTaskCompletion(at: indexPath.row)
        let updatedTask = self.presenter.getCurrentTasks()[indexPath.row]
        
        cell.configure(with: updatedTask, delegate: self, indexPath: indexPath)
        
        Task {
            do {
                self.presenter.handleSave(forOneTask: updatedTask)
                await logger.log("Task saved successfully (checkBox action)")
            }
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
        presenter.todos = todoTask
        reloadTasks()
        DispatchQueue.main.async {
            self.updateTodosCountForTaskCountLabel()
        }
    }
    
    func reloadTasks() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
