import Foundation
import CoreDataManager

protocol AnyTaskView: AnyScreen, AnyObject {}

protocol EditTaskView: AnyObject {
    func configureTask(with task: ToDoTask?)
}

class EditTaskPresenter {
    
    var currentTask: ToDoTask?
    private var view: EditTaskViewController
    private var onTaskSelected: EditTaskScreenHandler
    
    init(view: EditTaskViewController, onTaskSelected: @escaping EditTaskScreenHandler) {
        self.view = view
        self.onTaskSelected = onTaskSelected
    }
    
    func configure(with task: ToDoTask) {
        self.currentTask = task
        view.configureTask(with: task)
    }
    
    func updateTask(with text: String) {
        guard var currentTask = currentTask else { return }
        currentTask.todo = text
        self.currentTask = currentTask
    }
    
    func handleBackAction() {
        guard let currentTask = currentTask else { return }
        
        Task {
            await handleCoreDataSave(for: currentTask)
            self.onTaskSelected(currentTask)
        }
    }
    
    func handleCoreDataSave(for currentTask: ToDoTask) async {
        do {
            try await CoreDataManager.shared.save(forOneTask: currentTask)
            await logger.log("Task saved successfully (handleBack action")
        } catch {
            await logger.log("Failed to save task: \(error)")
        }
    }
}
