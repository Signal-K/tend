//
//  Focus.swift
//  Tend
//
//  Created by Liam Arbuckle on 15/7/2025.
//

import Foundation

import Foundation

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    var categoryTimes: [String: TimeInterval]
    var breakTime: TimeInterval
    var todos: [String]
    var completedTodos: [String]
}

struct Todo: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: String
    var completed: Bool = false
    
    init(id: UUID = UUID(), title: String, category: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.completed = completed
    }
}
