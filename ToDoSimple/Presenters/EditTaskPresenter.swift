import Foundation
import CoreDataManager

protocol AnyTaskView: AnyScreen, AnyObject {}

class EditTaskPresenter {
    
    private var task: ToDoTask?
    private var view: EditTaskViewController
    private var onTaskSelected: EditTaskScreenHandler
    
    init(view: EditTaskViewController, onTaskSelected: @escaping EditTaskScreenHandler) {
        self.view = view
        self.onTaskSelected = onTaskSelected
    }
    
    func configure(with task: ToDoTask) {
        self.task = task
        view.configureTask(with: task)
    }
    
    func handleBackAction(completion: @escaping () -> Void) async {
        guard var task = task else { return }
        if let updatedTitle = await view.taskTitleTextView.text, !updatedTitle.isEmpty {
            task.todo = updatedTitle
        }
        
        do {
            try await CoreDataManager.shared.save(forOneTask: task)
            print("Task saved successfully")
        } catch {
            print("Failed to save task: \(error)")
        }

        onTaskSelected(task)
    }
}
