import UIKit

class HomeTableViewController: UITableViewController {
    
    var someTasks = [ToDoTask(title: "Buy something", isCompleted: false),
                    ToDoTask(title: "Do the dishes", isCompleted: true),
                    ToDoTask(title: "Read a book", isCompleted: false)]
    
    let cellIdentifier = "ToDoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        
        
    }
}
