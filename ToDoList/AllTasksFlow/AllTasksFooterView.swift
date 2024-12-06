//
//  AllTasksFooterView.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 3.12.24.
//

import UIKit

class AllTasksFooterView: UIView {
    
    var editButtonCompletion: (() -> Void)?
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        addSubviews()
        setupConstrains()
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(number: Int) {
        title.text = String(number) + " " + "Задач"
        
    }
    
    private func setupView() {
        backgroundColor = .customBackgroundColor
    }
    
    private func addSubviews() {
        addSubview(title)
        addSubview(editImage)
    }
    
    private func setupConstrains() {
        NSLayoutConstraint.activate([
            editImage.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            editImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            editImage.heightAnchor.constraint(equalToConstant: 20),
            editImage.widthAnchor.constraint(equalToConstant: 20),
            
            title.centerYAnchor.constraint(equalTo: editImage.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 45),
            title.trailingAnchor.constraint(equalTo: editImage.leadingAnchor, constant: -5),
            title.heightAnchor.constraint(equalToConstant: 13),
            
        ])
    }
    
    private func setupSubViews() {
        title.font = UIFont(name: "SFPro-Regular", size: 11)
        title.textColor = UIColor.customWhite
        title.textAlignment = .center
        title.numberOfLines = 1
        
        editImage.image = UIImage(named: "Edit")
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(editTapped)
        )
        editImage.addGestureRecognizer(tap)
        editImage.isUserInteractionEnabled = true
        
    }
    
    @objc func editTapped() {
        editButtonCompletion!()
    }
    
}
