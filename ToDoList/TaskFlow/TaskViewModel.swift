//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 4.12.24.
//

import Foundation
import CoreData

protocol TaskViewModelDelegate: AnyObject {
    func taskDidSave()
    func didFailWithError(_ error: Error)
}

protocol TaskViewModelProtocol {
    var delegate: TaskViewModelDelegate? { get set }
    var isEditMode: Bool { get }
    var initialTitle: String { get }
    var initialDescription: String { get }
    func saveTask(title: String, description: String)
}

class TaskViewModel: TaskViewModelProtocol {
    weak var delegate: TaskViewModelDelegate?
    
    private let coreDataManager: CoreDataManager
    private let task: Todo?
    
    var isEditMode: Bool {
        return task != nil
    }
    
    var initialTitle: String {
        return task?.title ?? ""
    }
    
    var initialDescription: String {
        return task?.descriptionTodo ?? ""
    }
    
    init(coreDataManager: CoreDataManager, task: Todo? = nil) {
        self.coreDataManager = coreDataManager
        self.task = task
    }
    
    func saveTask(title: String, description: String) {
        guard !title.isEmpty else {
            delegate?.didFailWithError(ValidationError.emptyTitle)
            return
        }
        
        coreDataManager.performBackgroundTask { context in
            do {
                if let existingTask = self.task {
                    // Обновляем существующую задачу
                    let taskToUpdate = try context.existingObject(with: existingTask.objectID) as! Todo
                    taskToUpdate.title = title
                    taskToUpdate.descriptionTodo = description
                } else {
                    // Создаем новую задачу
                    let newTask = Todo(context: context)
                    newTask.title = title
                    newTask.descriptionTodo = description
                    newTask.dateCreated = Date()
                }
                
                try context.save()
                
                DispatchQueue.main.async {
                    self.delegate?.taskDidSave()
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    enum ValidationError: LocalizedError {
        case emptyTitle
        
        var errorDescription: String? {
            switch self {
            case .emptyTitle:
                return "Название задачи не может быть пустым"
            }
        }
    }
}

