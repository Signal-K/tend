//
//  TodoArchive.swift
//  Tend
//
//  Created by Liam Arbuckle on 13/7/2025.
//

import SwiftUI

struct ArchiveTasksView: View {
    @AppStorage("persistedTodos", store: .standard) private var persistedTodosData: Data = Data()

    private var allTodos: [Todo] {
        (try? JSONDecoder().decode([Todo].self, from: persistedTodosData)) ?? []
    }

    private var completedTodos: [Todo] {
        allTodos.filter { $0.completed }
    }

    private var incompleteTodos: [Todo] {
        allTodos.filter { !$0.completed }
    }

    private func groupByCategory(_ todos: [Todo]) -> [String: [Todo]] {
        Dictionary(grouping: todos, by: { $0.category })
    }

    var body: some View {
        NavigationView {
            List {
                if !incompleteTodos.isEmpty {
                    Section(header: Text("Incomplete Tasks")) {
                        let grouped = groupByCategory(incompleteTodos)
                        ForEach(grouped.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category.capitalized)) {
                                ForEach(grouped[category] ?? []) { todo in
                                    Label(todo.title, systemImage: "circle")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }

                if !completedTodos.isEmpty {
                    Section(header: Text("Completed Tasks")) {
                        let grouped = groupByCategory(completedTodos)
                        ForEach(grouped.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category.capitalized)) {
                                ForEach(grouped[category] ?? []) { todo in
                                    Label(todo.title, systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }

                if incompleteTodos.isEmpty && completedTodos.isEmpty {
                    Text("No tasks found.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("All Tasks")
            .listStyle(InsetGroupedListStyle())
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}
