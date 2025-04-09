import UIKit
import Combine
import CoreDataManager

protocol AnyTaskView: AnyScreen, AnyObject {}

/*class EditTaskPresenter {
    
    private var task: ToDoTask?
    private var editTaskViewController: EditTaskViewController
    
    init(viewController: EditTaskViewController, onTaskSelected: EditTaskScreenHandler?) {
        self.editTaskViewController = viewController
    }
    
    func configure(with task: ToDoTask) {
        self.task = task
        editTaskViewController.configureTask(with: task)
    }
    
    func handleBackAction(completion: @escaping () -> Void) async {
        guard var task = task else {
            completion()
            return
        }

        if let updatedTitle = editTaskViewController.taskTitleTextView.text, !updatedTitle.isEmpty {
            task.todo = updatedTitle
        }

        do {
            try await CoreDataManager.shared.save(forOneTask: task)
            print("Task saved successfully")
        } catch {
            print("Failed to save task: \(error)")
        }
        
        completion()
    }
}*/
