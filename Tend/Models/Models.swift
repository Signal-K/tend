//
//  Models.swift
//  Tend
//
//  Created by Liam Arbuckle on 17/6/2025.
//

import Foundation

struct Profile: Decodable {
  let username: String?
  let fullName: String?
  let website: String?

  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
  }
}

struct UpdateProfileParams: Encodable {
    let username: String
    let fullName: String
    let website: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case website
    }
}

struct ProjectInput {
    var id: String? = nil
    var name = ""
    var icon = "📁"
    var description = ""
    var category = ""
    var timeline = Date()
}

struct GroupInput {
    var id: String? = nil
    var name = ""
    var icon = "📂"
    var description = ""
}

struct TaskInput {
    var title = ""
    var description = ""
    var dueDate = Date()
    var repeatRule = ""
}

struct TaskWithGroupAndProject: Identifiable, Decodable {
    let id: UUID
    let title: String
    let due_date: Date?
    let group: TaskGroup?
    
    struct TaskGroup: Decodable {
        let id: UUID
        let name: String
        let icon: String
        let project: Project?
    }
    
    struct Project: Decodable {
        let id: UUID
        let name: String
        let icon: String
    }
}
