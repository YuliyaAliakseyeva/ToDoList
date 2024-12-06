//
//  AllTasksViewController.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 2.12.24.
//

import UIKit

class AllTasksViewController: UIViewController {
    private let viewModel: AllTasksViewModel
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var allTasksFooterView: AllTasksFooterView = {
        let view = AllTasksFooterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let image = UITableView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    init(viewModel: AllTasksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupView()
        setupSubViews()
        setupConstrains()
        setupSearchController()
        bindingViewModel()
    }
    
    private func bindingViewModel() {
        viewModel.loadNetworkTasks()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(allTasksFooterView)
    }
    
    private func setupView() {
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.customBlack
    }
    
    private func setupSubViews() {
        tableView.register(AllTasksTableViewCell.self, forCellReuseIdentifier: "AllTasksTableViewCell")
        tableView.backgroundColor = UIColor.customBlack
        tableView.dataSource = self
        tableView.delegate = self
        
        allTasksFooterView.configure(number: viewModel.filteredTasks.count)
        allTasksFooterView.editButtonCompletion = { [weak self] in
            guard let self else {return}
            let coreDataManager = CoreDataManager.shared
            let taskViewModel = TaskViewModel(coreDataManager: coreDataManager, task: nil)
            let taskViewController = TaskViewController(viewModel: taskViewModel)
            taskViewController.delegate = self
            self.navigationController?.pushViewController(taskViewController, animated: true)
        }
    }
    
    private func setupConstrains() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: allTasksFooterView.topAnchor),
            
            allTasksFooterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            allTasksFooterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            allTasksFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            allTasksFooterView.heightAnchor.constraint(equalToConstant: 84)
        ])
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
}

extension AllTasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AllTasksTableViewCell.id, for: indexPath) as? AllTasksTableViewCell else {return UITableViewCell()
        }
        
        let task = viewModel.filteredTasks[indexPath.row]
        cell.configure(task: task)
        cell.completion = { [weak self] in
            guard let self else {return}
            self.viewModel.toggleTaskCompletion(task)
        }
        return cell
    }
}

extension AllTasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = viewModel.filteredTasks[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            // Создаем действия для меню
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { _ in
                self?.handleEditTask(task)
            }
            
            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                self?.handleShareTask(task)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.handleDeleteTask(task)
            }
            return UIMenu(children: [editAction, shareAction, deleteAction])
        }
    }
    
    private func handleEditTask(_ task: Todo) {
        print("handleEditTask")
        let viewModel = TaskViewModel(coreDataManager: CoreDataManager.shared, task: task)
        let editTaskViewController = TaskViewController(viewModel: viewModel)
        editTaskViewController.delegate = self
        navigationController?.pushViewController(editTaskViewController, animated: true)
    }
    
    private func handleShareTask(_ task: Todo) {
        print("handleShareTask")
        if let title = task.title, let description = task.descriptionTodo {
            let text = "\(title)\n\(description)"
            let activityVC = UIActivityViewController(
                activityItems: [text],
                applicationActivities: nil
            )
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            present(activityVC, animated: true)
        }
    }
    
    private func handleDeleteTask(_ task: Todo) {
        print("handleDeleteTask")
        viewModel.deleteTask(task)
    }
}

extension AllTasksViewController: AllTasksViewModelDelegate {
    func tasksDidUpdate() {
        tableView.reloadData()
        allTasksFooterView.configure(number: viewModel.filteredTasks.count)
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AllTasksViewController: CreateTaskDelegate {
    func didAddTask() {
        viewModel.loadTasks()
    }
}

extension AllTasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchButtonClicked(searchText: searchText)
        tableView.reloadData()
    }
}

