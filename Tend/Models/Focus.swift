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
