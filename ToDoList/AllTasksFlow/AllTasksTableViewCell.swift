//
//  AllTasksTableViewCell.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 2.12.24.
//

import UIKit

class AllTasksTableViewCell: UITableViewCell {
    
    static let id = "AllTasksTableViewCell"
    
    var completion: (() -> Void)?
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTask: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var date: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkmark: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: .default,
            reuseIdentifier: reuseIdentifier
        )
        addSubviews()
        setupSubviews()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(title)
        contentView.addSubview(descriptionTask)
        contentView.addSubview(date)
        contentView.addSubview(checkmark)
    }
    
    private func setupSubviews() {
        contentView.layer.cornerRadius = 15
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(checkmarkTapped)
        )
        checkmark.addGestureRecognizer(tap)
        checkmark.isUserInteractionEnabled = true
        
        
        title.font = UIFont(name: "SFPro-Regular", size: 16)
        title.textAlignment = .left
        title.numberOfLines = 1
        
        descriptionTask.font = UIFont(name: "SFProText-Regular", size: 12)
        descriptionTask.textColor = UIColor.customWhite
        descriptionTask.textAlignment = .left
        descriptionTask.numberOfLines = 2
        
        date.font = UIFont(name: "SFProText-Regular", size: 12)
        date.textColor = UIColor.customWhite.withAlphaComponent(0.5)
        date.textAlignment = .left
        date.numberOfLines = 1
        date.layer.opacity = 0.5
    }
    
    private func setupLayouts() {
        NSLayoutConstraint.activate([
            checkmark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkmark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkmark.heightAnchor.constraint(equalToConstant: 24),
            checkmark.widthAnchor.constraint(equalToConstant: 24),
            
            title.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 8),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            title.centerYAnchor.constraint(equalTo: checkmark.centerYAnchor),
            title.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionTask.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            descriptionTask.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            descriptionTask.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            
            date.topAnchor.constraint(equalTo: descriptionTask.bottomAnchor, constant: 5),
            date.heightAnchor.constraint(equalToConstant: 16),
            date.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            date.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            date.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            
        ])
    }
    
    func configure(task: Todo) {
        let status = task.status
        
        if status == false {
            checkmark.image = UIImage(named: "Circle")
            title.textColor = UIColor.customWhite
            descriptionTask.textColor = UIColor.customWhite
        } else {
            checkmark.image = UIImage(named: "TickedCircle")
            title.textColor = UIColor.customWhite.withAlphaComponent(0.5)
            descriptionTask.textColor = UIColor.customWhite.withAlphaComponent(0.5)
        }
        
        if let title = task.title, let descriptionText = task.descriptionTodo, let date = task.dateCreated {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let fullDate = formatter.string(from: date)
            
            self.title.attributedText = status == false ? NSAttributedString(string: title) : NSAttributedString(string: title, attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ])
            self.descriptionTask.text = descriptionText
            self.date.text = fullDate
        }
    }
    
    @objc func checkmarkTapped() {
        completion?()
        print("checkmark tapped")
    }
}
