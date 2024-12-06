//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 2.12.24.
//
import Foundation
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            block(context)
        }
    }
    
    func createTask(title: String, description: String, completion: @escaping (Result<Todo, Error>) -> Void) {
        performBackgroundTask { context in
            let task = Todo(context: context)
            task.id = UUID()
            task.title = title
            task.descriptionTodo = description
            task.dateCreated = Date()
            task.status = false
            
            do {
                try context.save()
                
                // Получаем объект в главном контексте
                let mainContext = self.mainContext
                let mainTask = mainContext.object(with: task.objectID) as! Todo
                
                DispatchQueue.main.async {
                    completion(.success(mainTask))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchTasks() throws -> [Todo] {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        return try mainContext.fetch(fetchRequest)
    }
    
    func updateTask(_ task: Todo, newTitle: String, newDescription: String, completion: @escaping (Result<Todo, Error>) -> Void) {
        performBackgroundTask { context in
            do {
                let backgroundTask = try context.existingObject(with: task.objectID) as! Todo
                backgroundTask.title = newTitle
                backgroundTask.descriptionTodo = newDescription
                
                try context.save()
        
                let mainContext = self.mainContext
                let mainTask = mainContext.object(with: task.objectID) as! Todo
                
                DispatchQueue.main.async {
                    completion(.success(mainTask))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteTask(_ task: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        performBackgroundTask { context in
            do {
                let backgroundTask = try context.existingObject(with: task.objectID)
                context.delete(backgroundTask)
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateTaskCompletion(_ task: Todo, isCompleted: Bool, completion: @escaping (Result<Todo, Error>) -> Void) {
        performBackgroundTask { context in
            do {
                let backgroundTask = try context.existingObject(with: task.objectID) as! Todo
                backgroundTask.status = isCompleted
                
                try context.save()
                
                let mainContext = self.mainContext
                let mainTask = mainContext.object(with: task.objectID) as! Todo
                
                DispatchQueue.main.async {
                    completion(.success(mainTask))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    enum CoreDataError: LocalizedError {
        case failedToSaveContext
        case failedToFetchData
        case failedToDeleteData
        case objectNotFound
        
        var errorDescription: String? {
            switch self {
            case .failedToSaveContext:
                return "Не удалось сохранить данные"
            case .failedToFetchData:
                return "Не удалось загрузить данные"
            case .failedToDeleteData:
                return "Не удалось удалить данные"
            case .objectNotFound:
                return "Объект не найден"
            }
        }
    }
}
