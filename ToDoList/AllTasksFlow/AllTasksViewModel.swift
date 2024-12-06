//
//  AllTasksViewModel.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 2.12.24.
//

import Foundation
import CoreData

protocol AllTasksViewModelDelegate: AnyObject {
    func tasksDidUpdate()
    func showError(_ error: Error)
}

class AllTasksViewModel {
    private let coreDataManager: CoreDataManager
    private let networkManager: NetworkManager
    private(set) var tasks: [Todo] = []
    private(set) var filteredTasks: [Todo] = []
    
    weak var delegate: AllTasksViewModelDelegate?
    
    init(coreDataManager: CoreDataManager, networkManager: NetworkManager) {
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
        loadTasks()
    }
    
    func loadTasks() {
        do {
            tasks = try coreDataManager.fetchTasks()
            filteredTasks = tasks
            delegate?.tasksDidUpdate()
        } catch {
            delegate?.showError(error)
        }
    }
    
    func toggleTaskCompletion(_ task: Todo) {
        coreDataManager.updateTaskCompletion(task, isCompleted: !task.status) { [weak self] result in
            switch result {
            case .success:
                self?.loadTasks()
            case .failure(let error):
                self?.delegate?.showError(error)
            }
        }
    }
    
    func deleteTask(_ task: Todo) {
        coreDataManager.deleteTask(task) { [weak self] result in
            switch result {
            case .success:
                self?.loadTasks()
            case .failure(let error):
                self?.delegate?.showError(error)
            }
        }
    }
    
    func searchButtonClicked(searchText: String) {
        if searchText.isEmpty {
            loadTasks()
        } else {
            filteredTasks = tasks.filter { $0.title!.lowercased().contains(searchText.lowercased()) || $0.descriptionTodo!.lowercased().contains(searchText.lowercased()) }
            
        }
    }
    
    func saveTask(title: String, description: String) {
        coreDataManager.createTask(title: title, description: description) { [weak self] result in
            guard let self else {return}
            switch result {
            case .success(let task):
                print("задача сохранена - \(task.title ?? "")")
                self.loadTasks()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadNetworkTasks() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        
        if !isFirstLaunch {
            // Это первый запуск
            print("Первый запуск приложения")
            // Устанавливаем флаг, что приложение уже запускалось
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            UserDefaults.standard.synchronize()
            
            networkManager.getJoke { [weak self] result in
                guard let self else {return}
                switch result {
                case .success(let todosCodable):
                    let tasksFromNetwork = todosCodable.todos
                    for task in tasksFromNetwork {
                        self.saveTask(title: task.todo, description: task.todo)
                    }
                case .failure(let error):
                    print(error.description)
                }
                
            }
            
        } else {
            print("Приложение уже запускалось ранее")
        }
    }
}
