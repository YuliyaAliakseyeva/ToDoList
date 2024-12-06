//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 4.12.24.
//

import UIKit

protocol CreateTaskDelegate: AnyObject {
    func didAddTask()
}

class TaskViewController: UIViewController {
    
    private var viewModel: TaskViewModelProtocol
    
    weak var delegate: CreateTaskDelegate?
    
    private lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addSubviews()
        setupConstraints()
        setupSubviews()
        setupInitialData()
        setupKeyboardNotifications()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.customBlack
        navigationItem.largeTitleDisplayMode = .never
        let backImage = UIImage(systemName: "chevron.left")
        let backButton = UIButton(type: .system)
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle(" Назад", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addSubviews() {
        view.addSubview(titleTextField)
        view.addSubview(timeLabel)
        view.addSubview(descriptionTextView)
    }
    
    private func setupConstraints() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 41),
            
            timeLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 15),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupSubviews() {
        titleTextField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleTextField.textColor = UIColor.customWhite
        titleTextField.keyboardType = .default
        titleTextField.delegate = self
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.returnKeyType = .next
        titleTextField.becomeFirstResponder()
        titleTextField.textAlignment = .left
        titleTextField.placeholder = "Введите название"
        titleTextField.backgroundColor = UIColor.customBlack
        
        timeLabel.font = UIFont(name: "SFProText-Regular", size: 12)
        timeLabel.textColor = UIColor.customWhite.withAlphaComponent(0.5)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let fullDate = formatter.string(from: date)
        timeLabel.text = fullDate
        timeLabel.backgroundColor = UIColor.customBlack
        
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.textColor = .white
        descriptionTextView.keyboardType = .default
        descriptionTextView.delegate = self
        descriptionTextView.textAlignment = .left
        descriptionTextView.textColor = .label
        descriptionTextView.backgroundColor = UIColor.customBlack
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    }
    
    private func setupInitialData() {
        titleTextField.text = viewModel.initialTitle
        descriptionTextView.text = viewModel.initialDescription
        
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Описание задачи"
            descriptionTextView.textColor = .placeholderText
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func backButtonPressed() {
        print("backButtonPressed")
        viewModel.saveTask(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text
        )
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTapOutside() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let insets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardFrame.height,
            right: 0
        )
        
        additionalSafeAreaInsets = insets
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        additionalSafeAreaInsets = .zero
    }
    
}

extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = UIColor.customWhite
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание задачи"
            textView.textColor = .placeholderText
        }
    }
    
}

extension TaskViewController: TaskViewModelDelegate {
    func taskDidSave() {
        dismiss(animated: true)
        delegate?.didAddTask()
    }
    
    func didFailWithError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}



extension UITextView {
    
    func withDoneButton(toolBarHeight: CGFloat = 44) {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            print("Adding Done button to the keyboard makes sense only on iPhones")
            return
        }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: toolBarHeight))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        inputAccessoryView = toolBar
    }
    
}

