//
//  NetworkModels.swift
//  ToDoList
//
//  Created by Yuliya Vodneva on 2.12.24.
//


struct TodosCodable: Codable {
    let todos: [TodoCodable]
    let total, skip, limit: Int
}

struct TodoCodable: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
